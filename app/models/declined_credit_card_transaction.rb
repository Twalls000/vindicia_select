class DeclinedCreditCardTransaction < ActiveRecord::Base
  self.locking_column = :lock_version
  include AASM
  before_create :set_defaults
  before_validation :save_year
  belongs_to :declined_credit_card_batch
  has_many :audit_trails
  has_many :failure_audit_trails, class_name: 'FailureAuditTrail'
  has_many :success_audit_trails, class_name: 'SuccessAuditTrail'
  delegate :market_publication, to: :declined_credit_card_batch
  serialize :name_values

  validate :uniqueness_by_merchant_transaction_id_and_year

  INITIAL_CHARGE_STATUS = 'Failed'
  DEFAULT_CURRENCY = 'USD'
  DEFAULT_TOKENIZED = true
  DEFAULT_COUNTRY = 'US'

  aasm column: "status" do
    state :entry, initial: true
    state :queued_to_send, :sending, :pending, :in_error, :processed,
    :printed_bill, :no_reply, :genesys_error, :error_handled, :awaiting_send

    event :queue_to_vindicia do
      transitions from: :entry, to: :queued_to_send
    end
    event :sending_to_vindicia do
      transitions from: :queued_to_send, to: :sending
    end
    event :send_to_vindicia do
      transitions from: :sending, to: :pending
    end
    event :error_sending_to_vindicia do
      transitions from: :sending, to: :in_error
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
    event :failed_to_send_to_genesys do
      transitions from: :printed_bill, to: :genesys_error
      transitions from: :processed, to: :genesys_error
      transitions from: :error_handled, to: :genesys_error
    end
    event :failed_to_get_reply do
      transitions from: :pending, to: :no_reply
    end
    event :handle_error do
      transitions from: :in_error, to: :error_handled
    end
    event :wait_to_send do
      transitions from: :in_error, to: :awaiting_send
    end
    event :queue_for_send do
      transitions from: [:in_error, :awaiting_send], to: :entry
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

  scope :phoenix, ->{ by_gci_unit(MarketPublication::PHOENIX) }
  scope :non_phoenix, ->{ where("gci_unit NOT ?", MarketPublication::PHOENIX) }

  scope :summary_by_unit_for_date_range, ->(range) {
    find_by_sql(["
      SELECT  total.gci_unit,
              sites.name,
              count(total.id) as all_count,
              count(captured.id) as captured_count,
              sum(total.amount) as all_amount,
              sum(captured.amount) as captured_amount,
              sum(declined.amount) as declined_amount,
              count(declined.id) as declined_count,
              sum(pending.amount) as pending_amount,
              count(pending.id) as pending_count,
              sum(in_error.amount) as error_amount,
              count(in_error.id) as error_count
      FROM declined_credit_card_transactions total
          LEFT OUTER JOIN (
            SELECT * from declined_credit_card_transactions
            WHERE status = 'processed') AS captured
          ON total.id = captured.id
          LEFT OUTER JOIN (
            SELECT * from declined_credit_card_transactions
            WHERE status = 'printed_bill') AS declined
          ON total.id = declined.id
          LEFT OUTER JOIN (
            SELECT * from declined_credit_card_transactions
            WHERE status = 'pending') AS pending
            ON total.id = pending.id
          LEFT OUTER JOIN (
            SELECT * FROM declined_credit_card_transactions
            WHERE status = 'in_error') AS in_error
          ON total.id = in_error.id
          LEFT OUTER JOIN sites
          ON total.gci_unit = sites.gci_unit
      WHERE total.created_at BETWEEN ? AND ?
      GROUP BY total.gci_unit
      ORDER BY total.gci_unit
    ", range.begin, range.end])
  }

  def vindicia_fields
    attrs = attributes.except('id', 'batch_id', 'charge_status', 'created_at', 'credit_card_number', 'declined_credit_card_batch_id', 'declined_timestamp', 'gci_unit', 'market_publication_id', 'payment_method', 'payment_method_tokenized', 'pub_code', 'account_number', 'batch_date', 'status', 'updated_at', 'soap_id', 'fetch_soap_id', 'credit_card_expiration_date')
    attrs.merge!({
      'status'                      => charge_status,
      'timestamp'                   => Select.date_to_vindicia(declined_timestamp),
      'affiliate_id'                => id,
      'payment_method_id'           => payment_method_id,
      'previous_billing_count'      => previous_billing_count.to_i,
      'credit_card_account_hash'    => credit_card_account_hash,
      'payment_method_is_tokenized' => payment_method_tokenized
    })

    unless credit_card_expiration_date.blank?
      attrs['credit_card_expiration_date'] = Select.convert_gci_cc_expiration_date_to_vindicia(credit_card_expiration_date)
    end

    attrs.delete_if { |key,value| value.nil? }
    attrs.keys.each { |key| attrs[key.camelize(:lower)] = attrs.delete(key) }
    attrs
  end

  def status_update
    charge_status == "Captured" ? self.captured_funds : self.failed_to_capture_funds
  end

  def summary_status
    return "error"   if ['in_error',
                         'error_handled'].include?(status)
    return "success" if status == 'processed'

    return "pending" if ['entry',
                         'pending',
                         'queued_to_send'].include?(status)

    return "failure" if ['failure',
                         'printed_bill',
                         'no_reply'].include?(status)
  end

  def phoenix?
    gci_unit == MarketPublication::PHOENIX
  end

private
  def set_defaults
    self.currency = DEFAULT_CURRENCY
    self.charge_status = INITIAL_CHARGE_STATUS
    self.payment_method_tokenized = DEFAULT_TOKENIZED
    self.billing_address_country = DEFAULT_COUNTRY
    self.credit_card_account_hash = ''
  end

  def save_year
    self.year = declined_timestamp.year
  end

  def year=(year)
    super(year)
  end

  def uniqueness_by_merchant_transaction_id_and_year
    id_check_str = id.nil? ? "is not" : "!="
    unique = !self.class.where("merchant_transaction_id = ? AND year = ? AND id #{id_check_str} ?", merchant_transaction_id, year, id).first
    errors.add(:merchant_transaction_id, "is not unique by merchant_transaction_id and year") unless unique
    unique
  end
end
