class SendForCaptureJob < JobBase
  queue_as :send_for_capture

  before_perform do
    define_vindicia_class
  end

  def perform(transactions)
    Rails.logger.info("SendForCaptureJob params: #{ transactions.join(",") }\n#{ DateTime.now }")
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
