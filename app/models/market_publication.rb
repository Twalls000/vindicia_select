class MarketPublication < ActiveRecord::Base
  before_create :initialize_declined_credit_card_batch_keys
  attr_accessor :batch_date
  serialize :declined_credit_card_batch_keys

  PHOENIX = "PHX"

  scope :by_gci_unit_and_pub_code, -> (gci_unit, pub_code) { where(gci_unit:gci_unit, pub_code:pub_code) }

  validates :gci_unit, presence: true, length: { is: 4 }, unless: Proc.new { |mp| mp.gci_unit == PHOENIX }
  validates :pub_code, presence: true, length: { is: 2 }
  validates_uniqueness_of :pub_code, scope: :gci_unit
  # validates :declined_credit_card_batch_keys, presence: true
  validates :declined_credit_card_batch_size,
    presence: true, numericality: { only_integer: true, greater_than: 1 }
  validates :vindicia_batch_size,
    presence: true, numericality: { only_integer: true, greater_than: 1 }

  scope :phoenix, -> { where gci_unit: PHOENIX }
  scope :non_phoenix, -> { where.not gci_unit: PHOENIX }

  def select_next_batch
    declined_ccs = DeclinedCreditCard.summary(gci_unit:gci_unit, pub_code:pub_code,
      limit:declined_credit_card_batch_size, start_keys:declined_credit_card_batch_keys)

    self.declined_credit_card_batch_keys = declined_ccs.last.try(:batch_keys)
    save  if declined_credit_card_batch_keys

    declined_ccs
  end

  def to_s
    "#{gci_unit}-#{pub_code}"
  end

private
  def initialize_declined_credit_card_batch_keys
    unless gci_unit == PHOENIX
      batch_keys =
        DeclinedCreditCard.first_record_by_date(@batch_date, gci_unit, pub_code).first.try(:batch_keys) ||
          DeclinedCreditCard.new.batch_keys
      batch_keys[:pub_code] = pub_code

      self.declined_credit_card_batch_keys = batch_keys
    end
  end
end
