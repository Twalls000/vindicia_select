class MarketPublication < ActiveRecord::Base
  validates :gci_unit, presence: true, length: { is: 4 }
  validates :pub_code, presence: true, length: { is: 2 }
end
j
