class DeclinedBatches

  #
  # This section of code is to create the batches for the background
  # processor to later track every failed credit card in the centralized
  # table.
  #
  def self.process
    include_markets_and_pub.map do |mp|
      card_batch = mp.select_next_batch
      until card_batch.empty?
        submit_card_batch_job(card_batch, mp)
        card_batch = mp.select_next_batch
      end
    end
  end

  def self.include_markets_and_pub
    MarketPublication.all
  end

  def self.submit_card_batch_job(card_batch, mp)
    declined_batch = DeclinedCreditCardBatch.new
    declined_batch.start_keys = card_batch.first.batch_keys
    declined_batch.end_keys = card_batch.last.batch_keys
    declined_batch.gci_unit = mp.gci_unit
    declined_batch.pub_code = mp.pub_code
    declined_batch.save
    DeclinedBatchesJob.perform_later declined_batch.id
  end

  #
  # This section will take a defined batch of credit cards and add to the
  # centralized table.
  #
  def self.create_declined_batch(declined_batch_id)
    declined_batch = DeclinedCreditCardBatch.find(declined_batch_id)
    declined_batch.ready_to_process!
    credit_cards = DeclinedCreditCard.summary(gci_unit:declined_batch.gci_unit,
      pub_code:declined_batch.pub_code, limit:nil,
      start_keys:declined_batch.start_keys,
      end_keys:declined_batch.end_keys)

    credit_cards.each do |declined_cc|
      transaction = DeclinedCreditCardTransaction.new
      trans_attributes =
        begin
          load_transaction_attributes(declined_cc)
        rescue => e
          if e.message == "invalid date" && declined_cc.expiration_mmyy == 0
            transaction.status = "in_error"
            transaction.failure_audit_trails.build(event: "invalid credit card expiration date", exception: "#{e.class} - #{e.message}:\n#{e.backtrace.join("\n")}")
          else
            raise e
          end
          {}
        end

      # This is to have the aliased attributes as keys, and the aliases the values
      cc_aliased_attributes = declined_cc.attribute_aliases.invert
      declined_cc.attributes.each do |name, value|
        attribute = cc_aliased_attributes[name]
        if transaction.attributes.keys.include? attribute
          trans_attributes[attribute.to_sym] = value.try(:strip) || value
        end
      end
      transaction.gci_unit = declined_batch.gci_unit
      transaction.market_publication_id = declined_batch.market_publication.id
      transaction.attributes = trans_attributes
      transaction.declined_credit_card_batch = declined_batch
      transaction.save
    end

    finish_batch(declined_batch)
  end

  def self.finish_batch(batch)
    batch.create_end_timestamp = Time.now
    batch.done_processing
    batch.save
  end

  def self.load_transaction_attributes(declined_cc)
    {
      declined_timestamp:          declined_cc.declined_timestamp,
      credit_card_expiration_date: declined_cc.expiration_date,
      account_holder_name:         declined_cc.account_holder_name.squeezed,
      billing_address_line1:       declined_cc.billing_address_line1.squeezed,
      billing_address_line2:       declined_cc.billing_address_line2.squeezed,
      billing_addr_city:           declined_cc.billing_addr_city.squeezed,
      billing_address_district:    declined_cc.billing_address_district,
      billing_address_postal_code: declined_cc.billing_address_postal_code,
      auth_code:                   declined_cc.auth_code
    }
  end
end
