class GenerateFile

  attr_accessor :gci_unit, :pub_code, :run_date

  def initialize(gci_unit:, pub_code:)
    @gci_unit = gci_unit
    @pub_code = pub_code
    @run_date = Date.today
  end

  def include_markets_and_pub
    MarketPublciation.all.each { |mp| mp }
  end

  def process
    
  end
end
