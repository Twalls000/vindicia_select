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
        transaction.declined_timestamp = declined_cc.declined_timestamp
        transaction.merchant_transaction_id = declined_cc.merchant_transaction_id
        transaction.credit_card_expiration_date = declined_cc.credit_card_expiration_date
        transaction.account_holder_name = 
        transaction.billing_address_line1 = 
        transaction.
        transaction.
        transaction.
        transaction.
        transaction.
        transaction.
        

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
