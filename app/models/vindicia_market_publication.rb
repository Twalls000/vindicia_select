class VindiciaMarketPublication < ActiveRecord::Base
  validates :gci_unit, presence: true, length: { is: 4 }
  validates :pub_code, presence: true, length: { is: 2 }
  validates :vindicia_batch_size, numericality: { only_integer: true }
end
