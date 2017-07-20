class Dashboards::MarketPublicationsController < ApplicationController
  def show
    # gci_unit = params[:gci_unit]
    # pub_code = params[:pub_code]
    gci_unit, pub_code = params[:id].split('-')
    @market_pub = MarketPublication.by_gci_unit_and_pub_code(gci_unit, pub_code).first
    @statuses = DeclinedCreditCardTransaction.aasm.states.map(&:name)
    @total_by_transactions = DeclinedCreditCardTransaction.
                               created_within_n_days(21).
                               by_gci_unit(@market_pub.gci_unit).
                               by_pub_code(@market_pub.pub_code).
                               grouped_and_ordered_by_status.count
  end
end
