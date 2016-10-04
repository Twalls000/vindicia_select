class DashboardsController < ApplicationController

  # GET /dashboards
  # GET /dashboards.json
  def index
    @dashboards = []
    @batches = DeclinedCreditCardBatch.all.order("created_at desc").limit(20)
    @total_by_status = DeclinedCreditCardTransaction.where("created_at > ?",Time.now.beginning_of_day-21.days).group(:status).order(:status).count
    @statuses = DeclinedCreditCardTransaction.aasm.states.map(&:name)
    @market_pubs = MarketPublication.all
    @market_pubs = @market_pubs.inject({}) do |hash, mp|
      trans_for_mp = DeclinedCreditCardTransaction.where("created_at > ? AND gci_unit = ? AND pub_code = ?",Time.now.beginning_of_day-21.days, mp.gci_unit, mp.pub_code).group(:status).order(:status).count
      hash[mp] = trans_for_mp
      hash
    end
    # @trans_by_status = @statuses.reduce({}) do |hash,status|
    #   hash[status] =
    #     if @total_by_status[status.to_s]
    #       DeclinedCreditCardTransaction.where("created_at > ? AND status = ?",Time.now.beginning_of_day-21.days, status)
    #     else
    #       []
    #     end
    #   hash
    # end
    # binding.pry
  end

  # GET /dashboards/1
  # GET /dashboards/1.json
  def show
  end
end
