class SendForCaptureJob < ActiveJob::Base
  queue_as :send_for_capture

  def perform(transactions)
    Rails.logger.warn("Starting the SendForCaptureJob #{Time.now}")
    #
    # Complete and total hack!
    # This code redefines the Transaction class, instantiates an object,
    # and then saves the Vindicia::Transaction definition.
    # This code only exists because we will be retiring this project
    # once Vindicia goes live.

    vs = Vindicia::Schema.new
    transaction_class = vs.classes.select {|x| x.name == "TransactionValidationResponse"}.first
    my_needed_class_attributes = [:code, :merchant_transaction_id, :description, :soap_id]
    transaction_class.attributes = my_needed_class_attributes
    Vindicia::SingleClassBuilder.new transaction_class
    eval "Vindicia::TransactionValidationResponse"

    #
    # End Of Complete and total hack!
    #

    SendForCapture.send_transactions_for_capture(transactions)
    Rails.logger.warn("Completing the SendForCaptureJob #{Time.now}")
  end
end
