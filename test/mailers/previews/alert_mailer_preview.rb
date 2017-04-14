# Preview all emails at http://localhost:3000/rails/mailers/alert_mailer
class AlertMailerPreview < ActionMailer::Preview
  def alert
    begin
      raise "Test Error"
    rescue => e
      AlertMailer.alert_email(
        "#{e.class} - #{e.message}:\n#{e.backtrace.join("\n")}",
        "ClassName failed",
        "error",
        ["delayed_job"]
      )
    end
  end
end
