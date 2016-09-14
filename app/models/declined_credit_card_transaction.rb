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

  aasm column: "status" do
    state :entry, initial: true
    state :pending, :in_error

    event :sent_to_vindicia do
      transitions from: :entry, to: :pending
    end
    event :mark_in_error do
      transitions from: :entry, to: :in_error
    end
    event :captured_funds do
      transitions from: :pending, to: :processed
    end
    event :failed_to_capture_funds do
      transitions from: :pending, to: :printed_bill
    end
  end

  scope :by_gci_unit_and_pub_code, ->(gci_unit, pub_code){
    where(gci_unit:gci_unit, pub_code:pub_code)
  }

  scope :oldest_unsent, ->{
    where(status: "entry").order("created_at ASC")
  }

  def vindicia_fields
    attrs = attributes.except('created_at', 'updated_at', 'status',
      'charge_status', 'declined_timestamp', 'payment_method',
      'credit_card_number')

    attrs.merge!({
      # TODO: remove the following line when tokens supported by Vindicia
      'payment_method_tokenized' => false,
      'payment_method_id'        => 'CreditCard',
      'status'                   => charge_status,
      'timestamp'                => declined_timestamp,
      'subscription_id'          => merchant_transaction_id,
      'credit_card_account'      => credit_card_number
    })
    attrs.keys.each { |key| attrs[key.camelize(:lower)] = attrs.delete(key) }

    attrs
  end

  # Combine status to present back to Genesys
  def transaction_status
    case aasm.current_state
      when :entry, :pending then "pending"
      when :processed then "CC"
      when :printed_bill then "PB"
      when :in_error then "error"
    end
  end

private
  def set_defaults
    self.currency = DEFAULT_CURRENCY
    self.charge_status = INITIAL_CHARGE_STATUS
    self.payment_method_tokenized = DEFAULT_TOKENIZED
    self.billing_address_country = DEFAULT_COUNTRY
  end
end
