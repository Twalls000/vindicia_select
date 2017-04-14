module DataDog
  def self.send_event(message_text,message_title,alert_type,tags)
    tags += ["vindicia_select", "#{Rails.env}"]

    AlertMailer.alert_email(message_text,message_title,alert_type,tags).deliver_now
  end
end
