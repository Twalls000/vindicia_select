class DeclinedCreditCardBatch < ActiveRecord::Base
  before_create :set_defaults

  def set_defaults
    self.status = "New"
    self.run_timestamp = Time.now
  end
end
