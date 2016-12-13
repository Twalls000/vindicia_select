class StatusUpdateMailer < ApplicationMailer
  default to:   Rails.env.production? ? "wspencer@gannett.com,rverhey@gannett.com" : "rverhey@gannett.com",
          from: "vindicia_select_#{Rails.env}@gannett.com"

  def status_email
    mail subject: "Vindicia Select #{Rails.env.capitalize} Status"
  end
end
