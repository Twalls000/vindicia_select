class DeclinedCreditCardTransaction < ActiveRecord::Base
  include AASM
  before_create :set_defaults
  belongs_to :declined_credit_card_batch
  has_many :audit_trails
  delegate :market_publication, to: :declined_credit_card_batch
  serialize :name_values

  INITIAL_CHARGE_STATUS = 'Failed'
  DEFAULT_CURRENCY = 'USD'
  DEFAULT_TOKENIZED = true
  DEFAULT_COUNTRY = 'US'

  aasm column: "status" do
    state :entry, initial: true
    state :queued_to_send, :pending, :in_error, :processed, :printed_bill,
      :no_reply

    event :queue_to_vindicia do
      transitions from: :entry, to: :queued_to_send
    end
    event :send_to_vindicia do
      transitions from: :queued_to_send, to: :pending
    end
    event :error_sending_to_vindicia do
      transitions from: :queued_to_send, to: :in_error
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
    event :failed_to_get_reply do
      transitions from: :pending, to: :no_reply
    end
  end

  scope :created_within_n_days, ->(n){
    where("created_at > ?", Time.now.beginning_of_day - n.days)
  }
  scope :grouped_and_ordered_by_status, ->{
    group(:status).order(:status)
  }
  scope :by_gci_unit, ->(gci_unit){
    where(gci_unit: gci_unit)
  }
  scope :by_pub_code, ->(pub_code){
    where(pub_code: pub_code)
  }
  scope :oldest_unsent, ->{
    where(status: "entry").order("created_at ASC")
  }
  scope :get_queued_to_send_transactions, ->(ids){
    where("id in (?)", ids).where(:status=>"queued_to_send")
  }
  scope :find_by_merchant_transaction_id, ->(merchant_transaction_id){
    where(merchant_transaction_id:merchant_transaction_id)
  }
  scope :failed_billing_results, ->(days_before_failure) {
    pending.where("created_at<?", (Time.now-days_before_failure.days).beginning_of_day)
  }

  def vindicia_fields
    attrs = attributes.except('id', 'batch_id', 'charge_status', 'created_at', 'credit_card_number', 'declined_credit_card_batch_id', 'declined_timestamp', 'gci_unit', 'market_publication_id', 'payment_method', 'payment_method_tokenized', 'pub_code', 'account_number', 'batch_date', 'status', 'updated_at')
    attrs.merge!({
      'status'                      => charge_status,
      'timestamp'                   => Select.date_to_vindicia(declined_timestamp),
      'affiliate_id'                => id,
      # Will be the token when they are supported
      'payment_method_id'           => '4111_1111_1111_1111',
      'previous_billing_count'      => previous_billing_count.to_i,
      'credit_card_account_hash'    => credit_card_account_hash.to_s,
      'payment_method_is_tokenized' => payment_method_tokenized,
      'credit_card_expiration_date' => Select.convert_gci_cc_expiration_date_to_vindicia(credit_card_expiration_date),
    })

    # TODO: remove the following line when tokens supported by Vindicia
    attrs.merge!({ 'payment_method_is_tokenized' => false, 'credit_card_account' => 4111_1111_1111_1111 })
    # TODO: revmove the following line when the fields are populated properly
    attrs.merge!({ 'amount' => 25.0 })

    attrs.delete_if { |key,value| value.nil? }
    attrs.keys.each { |key| attrs[key.camelize(:lower)] = attrs.delete(key) }
    ap '********************************************************'
    ap attrs
    attrs
  end

  def status_update
    if charge_status == "Captured"
      self.captured_funds
    else
      self.failed_to_capture_funds
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
