class Api::DeclinedTransactionStatusController < ApiController
  
  def show
    if transaction = DeclinedCreditCardTransaction.find(params[:id])
      render json: {status: transaction.summary_status}, status: 200
    else
      render status: 404
    end
  end
end
