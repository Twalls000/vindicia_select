class DashboardsController < ApplicationController

  # GET /dashboards
  # GET /dashboards.json
  def index
    @dashboards = []
    @batches = DeclinedCreditCardBatch.all.order("created_at desc").limit(20)
    @total_by_status = DeclinedCreditCardTransaction.where("created_at > ?",Time.now.beginning_of_day-21.days).group(:status).order(:status).count
    @statuses = DeclinedCreditCardTransaction.aasm.states.map(&:name)
  end
 DeclinedCreditCardTransaction.group(:status).order(:status)
  # GET /dashboards/1
  # GET /dashboards/1.json
  def show
  end

  private
end
