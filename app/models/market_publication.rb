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
    declined_ccs = DeclinedCreditCard.summary(gci_unit, pub_code, declined_credit_card_batch_size, declined_credit_card_batch_keys)
    last_cc = declined_ccs.last
    declined_credit_card_batch_keys = last_cc.batch_keys

    save
    declined_ccs
  end

private
  def initialize_declined_credit_card_batch_keys(args = {})
    self.declined_credit_card_batch_keys =
      DeclinedCreditCard.first_record_by_date(@batch_date, gci_unit, pub_code).first.batch_keys
  end
end
