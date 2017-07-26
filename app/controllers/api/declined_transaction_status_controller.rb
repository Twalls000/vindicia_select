class Api::DeclinedTransactionStatusController < ApiController

  def show
    query = ["id = :query OR merchant_transaction_id = :query", { query: params[:id] }]
    @transaction = DeclinedCreditCardTransaction.where(*query).first

    if @transaction && @transaction.gci_unit.try(:upcase) == MarketPublication::PHOENIX
      json = { status:                  @transaction.summary_status,
               select_transaction_id:   @transaction.select_transaction_id,
               merchant_transaction_id: @transaction.merchant_transaction_id }
      render json: json
    else
      render json: {}, status: 404
    end
  end

end
