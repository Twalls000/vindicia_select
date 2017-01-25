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
        trans.vsbtch = batch_id(trans)
        trans.vsbdat = batch_date
        trans.vssts  = vssts
        trans.vsaust = charge_status
        trans.vsvord = select_transaction_id(trans)

        result = GenericTransaction.write_to_genesys(trans, :insert)
      end
    end
  end

  def fix_in_vs_database
    transactions = DeclinedCreditCardTransaction.where(merchant_transaction_id: @affected.keys)

    transactions.each do |trans|
      trans.status = status
      trans.batch_id = batch_id(trans)
      trans.batch_date = batch_date
      trans.charge_status = charge_status
      trans.select_transaction_id = select_transaction_id(trans)
      trans.save
    end
  end

  private

  def status
    "processed"
  end

  def batch_id(trans)
    "FX#{ Date.today.strftime("%m%d") }#{ trans.batch_id[-3..-1] }"
  end

  def batch_date
    Date.today.strftime("%Y%m%d").to_i
  end

  def charge_status
    "Captured"
  end

  def select_transaction_id(trans)
    @affected[trans.merchant_transaction_id.strip]
  end

  def vssts
    ""
  end
end
