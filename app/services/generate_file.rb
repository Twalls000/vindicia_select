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

    include_markets_and_pub.each do |gci_and_pub|
      DeclinedCreditCard.summary(gci_and_pub[:gci_unit].to_s).map do |declined_cc|
        transaction = DeclinedCreditCardTransaction.new
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

    batch
  end
end
