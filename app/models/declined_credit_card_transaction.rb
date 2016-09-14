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

  def vindicia_fields
    attrs = attributes.except('created_at', 'updated_at', 'status', 'payment_method_tokenized', 'charge_status', 'declined_timestamp', 'payment_method', 'credit_card_number', 'market_publication_id', 'declined_credit_card_batch_id', 'gci_unit', 'pub_code', 'batch_id')

    attrs.merge!({
      'status'                      => charge_status,
      'timestamp'                   => declined_timestamp.strftime("%Y-%m-%dT%H:%M:%S%:z"),
      'subscription_id'             => merchant_transaction_id,
      'payment_method_id'           => '', # Will be the token when they are supported
      'previous_billing_count'      => previous_billing_count.to_i,
      'credit_card_account_hash'    => credit_card_account_hash.to_s,
      'payment_method_is_tokenized' => payment_method_tokenized
    })

    # TODO: remove the following line when tokens supported by Vindicia
    attrs.merge!({ 'payment_method_is_tokenized' => false, 'credit_card_account' => 4444 })
    # TODO: revmove the following line when the fields are populated properly
    attrs.merge!({ 'amount' => 25.0 })

    attrs.delete_if { |key,value| value.nil? }
    attrs.keys.each { |key| attrs[key.camelize(:lower)] = attrs.delete(key) }

    attrs
  end

private
  def set_defaults
    self.currency = DEFAULT_CURRENCY
    self.charge_status = INITIAL_CHARGE_STATUS
    self.payment_method_tokenized = DEFAULT_TOKENIZED
    self.billing_address_country = DEFAULT_COUNTRY
  end
end
