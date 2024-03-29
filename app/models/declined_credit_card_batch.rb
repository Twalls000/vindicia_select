class DeclinedCreditCardBatch < ActiveRecord::Base
  validates :gci_unit, presence: true
  validates :pub_code, presence: true

  include AASM
  before_create :set_defaults
  serialize :start_keys
  serialize :end_keys

  has_many :declined_credit_card_transactions

  scope :created_within_n_days, ->(n){
    where("created_at > ?", Time.now.beginning_of_day - n.days)
  }
  scope :grouped_and_ordered_by_status, ->{
    group(:status).order(:status)
  }

  aasm column: "status" do
    state :entry, initial: true
    state :processing, :completed
    event :ready_to_process do
      transitions from: :entry, to: :processing
    end
    event :done_processing do
      transitions from: :processing, to: :completed
    end
  end

  def size
    declined_credit_card_transactions.count
  end

  def market_publication
    MarketPublication.by_gci_unit_and_pub_code(gci_unit, pub_code).first
  end

private
  def set_defaults
    self.create_start_timestamp = Time.now
  end

end
