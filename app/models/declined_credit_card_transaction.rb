class DeclinedCreditCardTransaction < ActiveRecord::Base
  include AASM
  before_create :set_defaults
  belongs_to :declined_credit_card_batch
  has_many :audit_trails
  delegate :market_publication, to: :declined_credit_card_batch

  INITIAL_CHARGE_STATUS = 'Failed'
  DEFAULT_CURRENCY = 'USD'
  DEFAULT_TOKENIZED = true
  DEFAULT_COUNTRY = 'US'
  attr_accessor :batch_id

  aasm column: "status" do
    state :entry, initial: true
    state :pending, :in_error

    event :sent_to_vindicia do
      transitions from: :entry, to: :pending
    end
    event :mark_in_error do
      transitions from: :entry, to: :in_error
    end
  end

  scope :by_gci_unit_and_pub_code, ->(gci_unit, pub_code){
    where(gci_unit:gci_unit, pub_code:pub_code)
  }

  scope :oldest_unsent, ->{
    where(status: "entry").order("created_at ASC")
  }

private
  def set_defaults
    self.currency = DEFAULT_CURRENCY
    self.charge_status = INITIAL_CHARGE_STATUS
    self.payment_method_tokenized = DEFAULT_TOKENIZED
    self.billing_address_country = DEFAULT_COUNTRY
  end
end
