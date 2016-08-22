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
    transactions = []
    include_markets_and_pub.each do |gci_and_pub|
      DeclinedCreditCard.summary(gci_and_pub[:gci_unit].to_s).map do |declined_cc|
        puts batch.declined_credit_card_transactions.build(declined_cc.attributes)
      end
    end
  end
end
