class AlertMailer < ApplicationMailer
  RECIPIENTS = ['rverhey@gannett.com']
  SENDER     = "Vindicia Select #{Rails.env.capitalize} <vindicia_select_#{Rails.env}@gannett.com>"

  default to:   RECIPIENTS,
          from: SENDER

  def alert_email(*args)
    @message_text, @message_title, @alert_type, @tags = args
    @message_text_arr = @message_text.split "\n"

    subject = "#{ @alert_type.titleize }: #{ @message_title } - Vindicia Select #{ Rails.env.capitalize } Alert"
    mail subject: subject
  end
end
