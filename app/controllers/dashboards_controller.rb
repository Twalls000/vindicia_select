class DashboardsController < ApplicationController

  # GET /dashboards
  # GET /dashboards.json
  def index
    @total_by_batches = DeclinedCreditCardBatch.created_within_n_days(7).grouped_and_ordered_by_status.count
    @batch_statuses = DeclinedCreditCardBatch.aasm.states.map(&:name)
    @total_by_transactions = DeclinedCreditCardTransaction.created_within_n_days(21).grouped_and_ordered_by_status.count
    @statuses = DeclinedCreditCardTransaction.aasm.states.map(&:name)
    @market_pubs = MarketPublication.order("gci_unit ASC")
  end

  # GET /dashboards/1
  # GET /dashboards/1.json
  def show
    @type = params[:id]
    @total_transactions =
      case @type
      when "batch"
        DeclinedCreditCardBatch.created_within_n_days(7).where(status: params[:status])
      when "transaction"
        DeclinedCreditCardTransaction.created_within_n_days(21).where(page_params)
    end
  end

  def about
  end

private
  def page_params
    params.permit(:status, :gci_unit, :pub_code)
  end
end
