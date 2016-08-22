class DeclinedCreditCardTransaction < ActiveRecord::Base
  before_save :set_defaults
  belongs_to :declined_credit_card_batch

  INITIAL_STATUS = "Failed"
  DEFAULT_CURRENCY = "USD"
  attr_accessor :pub_code, :batch_id

  def create_from_declined_transaction(declined)
    self.declined_timestamp = Time.now
    self.amount = declined.amount
    self.merchant_transaction_id = declined
  end

private
  def set_defaults
    self.currency = DEFAULT_CURRENCY
    self.status = INITIAL_STATUS
  end
end
