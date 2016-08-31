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
    declined_ccs = DeclinedCreditCard.summary(gci_unit, pub_code, declined_credit_card_batch_size, declined_credit_card_batch_keys)
    last_cc = declined_ccs.last
    declined_credit_card_batch_keys = {
      pub_code: pub_code,
      batch_id: last_cc.batch_id,
      batch_date: last_cc.batch_date,
      account_number: last_cc.account_number
    }

    save
    declined_ccs
  end
end
