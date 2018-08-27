class SummaryReportMailer < ApplicationMailer
  
  default to:   SummaryReports::RECIPIENTS,
          from: SummaryReports::SENDER

  def summary_report_email(records, range, csv, type)
    @records = records
    @range = range
    @type = type
    attachments["#{type}-#{range.begin.strftime('%F')}-#{range.end.strftime('%F')}.csv"] = csv
    subject = "Summary Report [#{type}] - Vindicia Select #{ Rails.env.capitalize }"
    mail subject: subject
  end
end
