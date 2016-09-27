class ReturnNotificationSetting < ActiveRecord::Base
  validates :checking_number_of_days, numericality: { only_integer: true }
  validates :range_to_check, numericality: { only_integer: true }
  validates :page, numericality: { only_integer: true }
  validates :days_before_failure, numericality: { only_integer: true }

  def set_failed_transactions
    DeclinedCreditCardTransaction.failed_billing_results(days_before_failure).each do |failed|
      failed.failed_to_get_reply!
    end
  end
end
