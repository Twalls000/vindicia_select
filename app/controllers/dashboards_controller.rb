class DashboardsController < ApplicationController

  # GET /dashboards
  # GET /dashboards.json
  def index
    @dashboards = []
    @total_by_batches = DeclinedCreditCardBatch.where("created_at > ?",Time.now.beginning_of_day-7.days).group(:status).order(:status).count
    @batch_statuses = DeclinedCreditCardBatch.aasm.states.map(&:name)
    @total_by_transactions = DeclinedCreditCardTransaction.where("created_at > ?",Time.now.beginning_of_day-21.days).group(:status).order(:status).count
    @statuses = DeclinedCreditCardTransaction.aasm.states.map(&:name)
    @market_pubs = MarketPublication.all
    @market_pubs = @market_pubs.inject({}) do |hash, mp|
      trans_for_mp = DeclinedCreditCardTransaction.where("created_at > ? AND gci_unit = ? AND pub_code = ?",Time.now.beginning_of_day-21.days, mp.gci_unit, mp.pub_code).group(:status).order(:status).count
      hash[mp] = trans_for_mp
      hash
    end
  end

  # GET /dashboards/1
  # GET /dashboards/1.json
  def show
    @type = params[:id]
    @total_transactions =
      case @type
      when "batch"
        DeclinedCreditCardBatch.where("created_at > ?",Time.now.beginning_of_day-7.days).where(status:params[:status])
      when "transaction"
        DeclinedCreditCardTransaction.where("created_at > ?",Time.now.beginning_of_day-7.days).where(page_params)
    end
  end

private
  def page_params
    params.permit(:status, :gci_unit, :pub_code)
  end
end
