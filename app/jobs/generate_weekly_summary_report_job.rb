class GenerateWeeklySummaryReportJob < JobBase
  queue_as :sumary_report

  def perform(date)
    range = DateRange.new(date).week_range
    records = DeclinedCreditCardTransaction.summary_by_unit_for_date_range(range)
    SummaryReportMailer.summary_report_email(records, range).deliver_now
  end
end
