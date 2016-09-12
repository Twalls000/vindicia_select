class DeclinedBatches

  #
  # This section of code is to create the batches for the background
  # processor to later track every failed credit card in the centralized
  # table.
  #
  def self.process
    include_markets_and_pub.map do |mp|
      declined_batch = DeclinedCreditCardBatch.new
      card_batch = mp.select_next_batch
      unless card_batch.empty?
        declined_batch.start_keys = card_batch.first.batch_keys
        declined_batch.end_keys = card_batch.last.batch_keys
        declined_batch.gci_unit = mp.gci_unit
        declined_batch.pub_code = mp.pub_code
        declined_batch.save
        DeclinedBatchesJob.perform_later declined_batch.id
      end
    end
  end

  def self.include_markets_and_pub
    MarketPublication.all
  end

  #
  # This section will take a defined batch of credit cards and add to the
  # centralized table.
  #
  def self.create_declined_batch(declined_batch_id)
    declined_batch = DeclinedCreditCardBatch.find(declined_batch_id)
    credit_cards = DeclinedCreditCard.summary(gci_unit:declined_batch.gci_unit,
      pub_code:declined_batch.pub_code, limit:nil, start_keys:declined_batch.start_keys,
      end_keys:declined_batch.end_keys)

    credit_cards.each do |declined_cc|
      transaction = declined_batch.declined_credit_card_transactions.build
      trans_attributes = load_transaction_attributes(declined_cc)

      # This is to have the aliased attributes as keys, and the aliases the values
      cc_aliased_attributes = declined_cc.attribute_aliases.invert

      declined_cc.attributes.each do |name, value|
        attribute = cc_aliased_attributes[name]
        if transaction.attributes.keys.include? attribute
          trans_attributes[attribute] = value.try(:strip) || value
        end
      end
      transaction.market_publication_id = transaction.market_publication.id
      transaction.attributes = trans_attributes
      transaction.save
    end

    finish_batch(declined_batch)
  end

  def self.finish_batch(batch)
    batch.create_end_timestamp = Time.now
    batch.save
  end

  def self.load_transaction_attributes(declined_cc)
    {
      declined_timestamp:          declined_cc.declined_timestamp,
      merchant_transaction_id:     declined_cc.merchant_transaction_id,
      credit_card_expiration_date: declined_cc.expiration_date,
      account_holder_name:         declined_cc.account_holder_name,
      billing_address_line1:       declined_cc.billing_address_line1,
      billing_address_line2:       declined_cc.billing_address_line2,
      billing_addr_city:           declined_cc.billing_addr_city,
      billing_address_district:    declined_cc.billing_address_district,
      billing_address_postal_code: declined_cc.billing_address_postal_code
    }
  end
end
