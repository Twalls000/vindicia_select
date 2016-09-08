class MarketPublication < ActiveRecord::Base
  before_create :initialize_declined_credit_card_batch_keys
  attr_accessor :batch_date
  serialize :declined_credit_card_batch_keys

  validates :gci_unit, presence: true, length: { is: 4 }
  validates :pub_code, presence: true, length: { is: 2 }
  validates_uniqueness_of :pub_code, scope: :gci_unit
  # validates :declined_credit_card_batch_keys, presence: true
  validates :declined_credit_card_batch_size,
    presence: true, numericality: { only_integer: true }
  validates :vindicia_batch_size,
    presence: true, numericality: { only_integer: true }

  def select_next_batch
    declined_ccs = DeclinedCreditCard.summary(gci_unit:gci_unit, pub_code:pub_code,
      limit:declined_credit_card_batch_size, start_keys:declined_credit_card_batch_keys)
    self.declined_credit_card_batch_keys = declined_ccs.last.batch_keys
    save
    declined_ccs
  end

private
  def initialize_declined_credit_card_batch_keys
    batch_keys =
      DeclinedCreditCard.first_record_by_date(@batch_date, gci_unit, pub_code).first.try(:batch_keys) ||
        DeclinedCreditCard.new.batch_keys
    batch_keys[:pub_code] = pub_code

    self.declined_credit_card_batch_keys = batch_keys
  end
end
