class Api::DeclinedTransactionStatusController < ApiController
  before_action :find_transaction

  def show
    if @transaction && @transaction.gci_unit.try(:upcase) == "PHX"
      render json: {status: transaction.summary_status}, status: 200
    else
      render status: 404
    end
  end

  private
  
  def find_transaction
    @transaction = DeclinedCreditCardTransaction.find(params[:id])
  end

  def ensure_gci_unit_phx
  end
end
