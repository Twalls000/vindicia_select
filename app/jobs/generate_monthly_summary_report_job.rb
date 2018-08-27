class GenerateMonthlySummaryReportJob < JobBase
  queue_as :summary_report

  def perform(date)
    type = "Monthly"
    range = DateRange.new(date).month_range
    records = DeclinedCreditCardTransaction.summary_by_unit_for_date_range(range)
    csv = SummaryReport.new(records, range: range).to_csv
    SummaryReportMailer.summary_report_email(records, range, csv, type).deliver_now
  end
end
