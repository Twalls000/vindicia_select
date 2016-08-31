class MarketPublication < ActiveRecord::Base
  validates :gci_unit, presence: true, length: { is: 4 }
  validates :pub_code, presence: true, length: { is: 2 }
  validates_uniqueness_of :pub_code, scope: :gci_unit
  validates :declined_credit_card_batch_keys, presence: true
  validates :declined_credit_card_batch_size,
    presence: true, numericality: { only_integer: true }
  validates :vindicia_batch_size,
    presence: true, numericality: { only_integer: true }

  serialize :declined_credit_card_batch_keys

  def select_next_batch

  end
end
