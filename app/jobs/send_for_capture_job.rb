class SendForCaptureJob < ActiveJob::Base
  queue_as :send_for_capture

  around_perform do |job, block|
    Rails.logger.warn("Starting the SendForCaptureJob #{Time.now}")

    begin
      define_vindicia_class
      block.call
    rescue => e
      # Send email
      raise e
    end

    Rails.logger.warn("Completing the SendForCaptureJob #{Time.now}")
  end

  def perform(transactions)
    SendForCapture.send_transactions_for_capture(transactions)
  end

private

  # Complete and total hack!
  # This code redefines the Transaction class, instantiates an object,
  # and then saves the Vindicia::Transaction definition.
  # This code only exists because we will be retiring this project
  # once Vindicia goes live.
  def define_vindicia_class
    vs = Vindicia::Schema.new
    transaction_class = vs.classes.select {|x| x.name == "TransactionValidationResponse"}.first
    my_needed_class_attributes = [:code, :merchant_transaction_id, :description, :soap_id]
    transaction_class.attributes = my_needed_class_attributes
    Vindicia::SingleClassBuilder.new transaction_class
    eval "Vindicia::TransactionValidationResponse"
  end
  #
  # End Of Complete and total hack!
  #

end
