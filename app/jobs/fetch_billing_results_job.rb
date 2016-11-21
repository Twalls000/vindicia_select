class FetchBillingResultsJob < JobBase
  queue_as :fetch_billing_results

  before_perform do
    define_vindicia_class
  end

  def perform
    return_notification_setting = ReturnNotificationSetting.first

    start_time = (Date.today - return_notification_setting.checking_number_of_days.days).in_time_zone("Pacific Time (US & Canada)").end_of_day + 1.second
    end_time = (Date.today - return_notification_setting.range_to_check.days).in_time_zone("Pacific Time (US & Canada)").end_of_day
    fetch_billing_results = FetchBillingResults.new(page_size:return_notification_setting.page,
      start_timestamp: start_time, end_timestamp: end_time)
    fetch_billing_results.fetch_billing_results
  end

private

  # Complete and total hack!
  # This code redefines the Transaction class, instantiates an object,
  # and then saves the Vindicia::Transaction definition.
  # This code only exists because we will be retiring this project
  # once Vindicia goes live.
  def define_vindicia_class
    vs = Vindicia::Schema.new
    transaction_class = vs.classes.select {|x| x.name == "Transaction"}.first
    my_needed_class_attributes = [:amount, :currency, :division_number, :merchant_transaction_id,
      :name_values, :timestamp, :vid, :auth_code, :status, :division_number, :select_transaction_id,
      :subscription_id, :subscription_start_date, :customer_id, :payment_method_id,
      :payment_method_is_tokenized, :credit_card_account, :credit_card_account_hash,
      :credit_card_expiration_date, :account_holder_name, :billing_address_line_1,
      :billing_address_district, :billing_address_postal_code, :billing_address_country, :soap_id]
    transaction_class.attributes = my_needed_class_attributes
    Vindicia::SingleClassBuilder.new transaction_class
    eval "Vindicia::Transaction"
  end
  # End Of Complete and total hack!
end
