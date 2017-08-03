class Api::DeclinedTransactionStatusController < ApiController

  def show
    # If you turn a string into an integer then back into a string again, if it
    # stays the same as the original then it was most likely a number
    # originally, so it will be the ID, since our merchant_transaction_ids are
    # alpha-numeric. But, if it was alpha-numeric to begin with, turning it into
    # an integer then back in the string will change it, so it will not match,
    # and that will be the merchant_transaction_id.
    # ex: "123-ABC-456" -> 123 -> "123" != "123-ABC-456"
    #     "15"          -> 15  -> "15"  == "15"
    query =
      if params[:id].to_i.to_s == params[:id]
        { id: params[:id] }
      else
        { merchant_transaction_id: params[:id] }
      end
    @transaction = DeclinedCreditCardTransaction.where(query).first

    if @transaction && @transaction.gci_unit.try(:upcase) == MarketPublication::PHOENIX
      json = { id:                      @transaction.id,
               status:                  @transaction.summary_status,
               select_transaction_id:   @transaction.select_transaction_id,
               merchant_transaction_id: @transaction.merchant_transaction_id }
      render json: json
    else
      render json: {}, status: 404
    end
  end

end
