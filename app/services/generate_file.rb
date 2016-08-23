class GenerateFile

  attr_accessor :run_date

  def initialize
    @run_date = Date.today
  end

  def include_markets_and_pub
    MarketPublication.all
  end

  def process
    batch = DeclinedCreditCardBatch.new

    include_markets_and_pub.each do |mp|
      DeclinedCreditCard.summary(mp.gci_unit, mp.pub_code).map do |declined_cc|
        transaction = DeclinedCreditCardTransaction.new
        trans_attributes = {
          declined_timestamp:          declined_cc.declined_timestamp,
          merchant_transaction_id:     declined_cc.merchant_transaction_id,
          credit_card_expiration_date: declined_cc.expiration_date,
          account_holder_name:         declined_cc.name.strip,
          billing_address_line1:       declined_cc.address_line1.strip,
          billing_address_line2:       declined_cc.address_line2.strip,
          billing_addr_city:           declined_cc.city_state.split(",").first.strip,
          billing_address_district:    declined_cc.city_state.split(",").last.strip,
          billing_address_postal_code: declined_cc.zip_code,
          billing_address_country:     "US"
        }

        transaction.attributes = trans_attributes

        # This is to have the aliased attributes as keys, and the aliases the values
        cc_aliased_attributes = declined_cc.attribute_aliases.invert

        declined_cc.attributes.each do |name, value|
          if transaction.attributes.keys.include? cc_aliased_attributes[name]
            transaction.send("#{cc_aliased_attributes[name]}=", value)
          end
        end

        batch.declined_credit_card_transactions << transaction
      end
    end

    batch.save
  end
end
