class GenerateWeeklySummaryReportJob < JobBase
  queue_as :summary_report

  def perform(date)
    type = "Weekly"
    range = DateRange.new(date).week_range
    records = DeclinedCreditCardTransaction.summary_by_unit_for_date_range(range)
    csv = SummaryReport.new(records, range: range).to_csv
    SummaryReportMailer.summary_report_email(records, range, csv, type).deliver_now
  end
  
end
