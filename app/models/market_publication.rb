class MarketPublication < ActiveRecord::Base
  validates :gci_unit, presence: true, length: { is: 4 }
  validates :pub_code, presence: true, length: { is: 2 }
  validates_uniqueness_of :pub_code, scope: :gci_unit
  validates :vindicia_batch_size, numericality: { only_integer: true }
  validates :import_time_seconds, numericality: { only_integer: true }
  validates :end_last_range, presence: true
  validates :start_last_range, presence: true
  validate  :date_range

  def date_range
    if end_last_range && start_last_range && start_last_range > end_last_range
      errors.add(:start_last_range, "is not valid")
    end
  end

  def select_next_batch
    end_last_range
    
  end
end
