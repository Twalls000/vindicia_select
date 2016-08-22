class DeclinedCreditCardTransaction < ActiveRecord::Base
  before_save :set_defaults

  INITIAL_STATUS = "Failed"
  DEFAULT_CURRENCY = "USD"

  def set_defaults
    self.currency = DEFAULT_CURRENCY
    self.status = INITIAL_STATUS
  end
end
