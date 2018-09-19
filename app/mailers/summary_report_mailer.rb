class SummaryReportMailer < ApplicationMailer
  
  default from: SummaryReports::SENDER

  def summary_report_email(records, range, csv, type)
    @records = records
    @range = range
    @type = type
    #attachments["#{type}-#{range.begin.strftime('%F')}-#{range.end.strftime('%F')}.csv"] = csv
    attachments["#{type}-#{@range}.csv"] = csv
    subject = "Summary Report [#{type}] - Vindicia Select #{ Rails.env.capitalize }"
    
    mail subject: subject, to: recipients(type)
  end

  def recipients(type)
    fall_back_recipient = 'szaidi@gannett.com'

    case type.downcase
    when 'ytd'
      #YTD_REPORT_RECIPIENTS
      AppConfig.get_config('YTD_SUMMARY_REPORT_RECIPIENTS', fall_back_recipient)
    when 'weekly'
      #WEEKLY_REPORT_RECIPIENTS
      AppConfig.get_config('WEEKLY_SUMMARY_REPORT_RECIPIENTS', fall_back_recipient)
    when 'monthly' 
      #MONTHLY_REPORT_RECIPIENTS
      AppConfig.get_config('MONTHLY_SUMMARY_REPORT_RECIPIENTS', fall_back_recipient)
    end
  end

end
