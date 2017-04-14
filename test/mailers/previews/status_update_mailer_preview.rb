# Preview all emails at http://localhost:3000/rails/mailers/status_update_mailer
class StatusUpdateMailerPreview < ActionMailer::Preview
  def status
    StatusUpdateMailer.status_email
  end
end
