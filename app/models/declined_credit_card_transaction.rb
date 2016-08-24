class DeclinedCreditCardTransaction < ActiveRecord::Base
  before_create :set_defaults
  belongs_to :declined_credit_card_batch

  INITIAL_STATUS = 'Failed'
  DEFAULT_CURRENCY = 'USD'
  DEFAULT_TOKENIZED = true
  DEFAULT_COUNTRY = 'US'
  attr_accessor :pub_code, :batch_id

private
  def set_defaults
    self.currency = DEFAULT_CURRENCY
    self.status = INITIAL_STATUS
    self.payment_method_tokenized = DEFAULT_TOKENIZED
    self.billing_address_country = DEFAULT_COUNTRY
  end
end
