class DeclinedCreditCardBatch < ActiveRecord::Base
  before_create :set_defaults
  has_many :declined_credit_card_transactions
  def set_defaults
    self.status = "New"
    self.run_timestamp = Time.now
  end
end
