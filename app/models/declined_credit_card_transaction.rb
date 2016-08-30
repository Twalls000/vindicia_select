class DeclinedCreditCardTransaction < ActiveRecord::Base
  include AASM
  before_create :set_defaults
  belongs_to :declined_credit_card_batch
  has_many :audit_trails

  INITIAL_STATUS = 'Failed'
  DEFAULT_CURRENCY = 'USD'
  DEFAULT_TOKENIZED = true
  DEFAULT_COUNTRY = 'US'
  attr_accessor :pub_code, :batch_id

  aasm column: "status" do
    after_all_transitions :update_audit_trail_on_state_change
    state :entry, initial: true, after_enter: :update_audit_trail_on_state_change
  end

private
  def set_defaults
    self.currency = DEFAULT_CURRENCY
    self.status = INITIAL_STATUS
    self.payment_method_tokenized = DEFAULT_TOKENIZED
    self.billing_address_country = DEFAULT_COUNTRY
  end

  def update_audit_trail_on_state_change
    audit_trails.build event: status, changed_values: changes
  end
end
