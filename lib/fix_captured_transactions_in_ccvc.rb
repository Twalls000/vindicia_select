# January 2017
# This class has methods that attempt to correct an issue where transactions
# were sent back to CCVC when they shouldn't have. Some transcactions came back
# from Vindicia as captured, but that wasn't updated in CCVC. These methods will
# update the CCVC records that were affected.

class FixCapturedTransactionsInCcvc
  attr_reader :gci_units
  # gci_units: A list of GCI Units, defaults to all
  # ignore: List of GCI Units to ignore
  # affected: A hash of all affected accounts, with merchant_transaction_id as
  #   key, select_transaction_id as value
  def initialize(gci_units: [], ignore: [], affected: {})
    gci_units = Array(gci_units)
    ignore = Array(ignore)
    @affected = affected

    @gci_units =
      if gci_units.first
        gci_units
      else
        MarketPublication.select(:gci_unit).distinct.map(&:gci_unit) - ignore
      end
  end

  def fix
    @gci_units.each do |unit|
      transactions = []
      @affected.keys.each_slice(1000) do |slice|
        transactions += DeclinedCreditCard.on_db(unit).where(vstrid: slice)
      end

      transactions.each do |trans|
        trans.vsbtch = "FX#{ Date.today.strftime("%m%d") }#{ trans.vsbtch[-3..-1] }"
        trans.vsbdat = Date.today.strftime("%Y%m%d").to_i
        trans.vssts  = ""
        trans.vsaust = "Captured"
        trans.vsvord = @affected[trans.vstrid.strip]

        result = GenericTransaction.write_to_genesys(trans, :insert)
      end
    end
  end
end
