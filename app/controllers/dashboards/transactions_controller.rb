class Dashboards::TransactionsController < ApplicationController
  def index
  end

  def show
    @transaction = DeclinedCreditCardTransaction.find_by(id: params[:id])
    @audit_trails = @transaction.audit_trails
  end
  end
end
