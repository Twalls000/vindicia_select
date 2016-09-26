class FetchBillingResultsJob < ActiveJob::Base
  queue_as :fetch_billing_results

  def perform
    #
    # Complete and total hack!
    # This code redefines the Transaction class, instantiates an object,
    # and then saves the Vindicia::Transaction definition.
    # This code only exists because we will be retiring this project
    # once Vindicia goes live.

    vs = Vindicia::Schema.new
    transaction_class = vs.classes.select {|x| x.name == "Transaction"}.first
    my_needed_class_attributes = [:amount, :currency, :division_number, :merchant_transaction_id,
      :name_values, :timestamp, :vid, :auth_code, :status, :division_number, :select_transaction_id,
      :subscription_id, :subscription_start_date, :customer_id, :payment_method_id,
      :payment_method_is_tokenized, :credit_card_account, :credit_card_account_hash,
      :credit_card_expiration_date, :account_holder_name, :billing_address_line_1,
      :billing_address_district, :billing_address_postal_code, :billing_address_country]
    transaction_class.attributes = my_needed_class_attributes
    Vindicia::SingleClassBuilder.new transaction_class
    eval "Vindicia::Transaction"

    #
    # Complete and total hack!
    #

    # TODO do we add these to the submission? Make them scalable?
    # in short, these settings are for testing.
    fetch_billing_results = FetchBillingResults.new(page_size:10,
      start_timestamp:Time.now-7.days, end_timestamp:Time.now-4.days)
    fetch_billing_results.fetch_billing_results
  end
end
