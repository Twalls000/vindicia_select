module DashboardsHelper
  def page_title(type)
    type=="batch" ? "Declined Credit Card Batch" : "Declined Credit Card Transaction"
  end
end
