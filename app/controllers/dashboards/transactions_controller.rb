class Dashboards::TransactionsController < ApplicationController
  def index
  end

  def show
    @transaction = DeclinedCreditCardTransaction.find_by(id: params[:id])
    @audit_trails = @transaction.audit_trails
  end

  def search
    @query =
      if params[:trans_id].to_i.to_s == params[:trans_id]
        { id: params[:trans_id] }
      else
        { merchant_transaction_id: params[:trans_id] }
      end

    @transaction = DeclinedCreditCardTransaction.select(:id).where(@query).first

    if @transaction
      redirect_to dashboards_transaction_url(@transaction.id)
    else
      flash[:error] = "Transaction not found"
      render :index
    end
  end
end
