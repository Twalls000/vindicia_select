class SummaryReportMailer < ApplicationMailer
  RECIPIENTS = 'wspencer@gannett.com'
  SENDER     = "Vindicia Select #{Rails.env.capitalize} <vindicia_select_#{Rails.env}@gannett.com>"

  default to:   RECIPIENTS,
          from: SENDER

  def summary_report_email(records, range)
    @records = records
    @range = range

    subject = "Summary Report - Vindicia Select #{ Rails.env.capitalize }"
    mail subject: subject
  end
end
