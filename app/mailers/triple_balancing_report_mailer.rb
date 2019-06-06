class TripleBalancingReportMailer < ApplicationMailer
  
  RECIPIENTS = Rails.env.production? ? ["nssc-gl@gannett.com"] : ["twalls@gannett.com"]
  SENDER     = "Vindicia Select #{Rails.env.capitalize} <vindicia_select_#{Rails.env}@gannett.com>"

  default from: SENDER
  

  def summary_report_email(records, csv)
    @records = records
    type = "triple-balancing-report"
    attachments["triple-balancing-report-#{Date.today.iso8601}.csv"] = csv
    subject = "Vindicia Select Report [#{type}] - Vindicia Select #{ Rails.env.capitalize }"
    
    mail subject: subject, to: RECIPIENTS
  end
end
