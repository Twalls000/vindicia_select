class GenerateFile

  attr_accessor :gci_unit, :pub_code, :run_date

  def initialize(gci_unit:, pub_code:)
    @gci_unit = gci_unit
    @pub_code = pub_code
    @run_date = Date.today
  end

  def include_markets_and_pub
    MarketPublciation.all
  end

  def process
    batch = DeclinedCreditCardBatch.new
    transactions = batch.build
    # include_markets_and_pub.each do |gci_and_pub|
    #   transactions = DeclinedCreditCard.summary(gci_and_pub[:gci_unit]).map do |declined_cc|
    #     DeclinedCreditCardTransaction.new
    #   end
    # end
  end
end
