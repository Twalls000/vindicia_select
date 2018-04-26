class FetchBillingResultsJob < JobBase
  queue_as :sumary_report

  def perform(range)
    records = DeclinedCreditCardTransaction.summary_by_unit_for_date_range(range)
    SummaryReportMailer.summary_report_email(records, range).delivery_now
  end
end
