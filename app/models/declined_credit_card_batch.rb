class DeclinedCreditCardBatch < ActiveRecord::Base
  validates :gci_unit, presence: true
  validates :pub_code, presence: true

  include AASM
  before_create :set_defaults
  serialize :start_keys
  serialize :end_keys

  has_many :declined_credit_card_transactions

  aasm column: "status" do
    state :new, initial: true
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
