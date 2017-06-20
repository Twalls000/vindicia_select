class Api::DeclinedTransactionStatusController < ApiController

  def show
    @transaction = DeclinedCreditCardTransaction.find_by(id: params[:id])

    if @transaction && @transaction.gci_unit.try(:upcase) == "PHX"
      json = { status:                  @transaction.summary_status,
               select_transaction_id:   @transaction.select_transaction_id,
               merchant_transaction_id: @transaction.merchant_transaction_id }
      render json: json
    else
      render json: {}, status: 404
    end
  end

end
