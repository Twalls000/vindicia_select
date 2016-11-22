class Api::DeclinedTransactionStatusController < ApiController

  def show
    @transaction = DeclinedCreditCardTransaction.find(params[:id])

    if @transaction && @transaction.gci_unit.try(:upcase) == "PHX"
      render json: {status: @transaction.summary_status}
    else
      render json: {}, status: 404
    end
  end

end
