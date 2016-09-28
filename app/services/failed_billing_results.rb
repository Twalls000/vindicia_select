class FailedBillingResults

  #
  # This section of code is to create the batches for the background
  # processor to later track every failed credit card in the centralized
  # table.
  #
  def self.process
    # Get the transactions and mark them as failed
    ReturnNotificationSettingJob.perform_later
  end

  def self.failed_billing_results
    ReturnNotificationSetting.first.return_notification_setting
  end
end
