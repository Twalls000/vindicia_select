class DeclinedCreditCardBatch < ActiveRecord::Base
  before_create :set_defaults

  has_many :declined_credit_card_transactions

  INITIAL_STATUS = "New"

private
  def set_defaults
    self.status = INITIAL_STATUS
    self.create_start_timestamp = Time.now
  end

end
