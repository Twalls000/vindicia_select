class DeclinedCreditCardBatch < ActiveRecord::Base
  before_create :set_defaults
  serialize :start_keys
  serialize :end_keys

  has_many :declined_credit_card_transactions

  INITIAL_STATUS = "New"

  def size
    declined_credit_card_transactions.count
  end

private
  def set_defaults
    self.status = INITIAL_STATUS
    self.create_start_timestamp = Time.now
  end

end
