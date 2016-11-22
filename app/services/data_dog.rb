module DataDog
  DATADOG_API_KEY = ENV["DATADOG_API_KEY"]

  def self.new_client
    Dogapi::Client.new(DATADOG_API_KEY)
  end

  def self.new_event(message_text,message_title,alert_type,tags)
    Dogapi::Event.new(message_text,
      msg_title: message_title,
      alert_type: alert_type,
      tags: tags
    )
  end

  def self.send_event(message_text,message_title,alert_type,tags)
    tags = ["vindicia_select", "environment:#{Rails.env}"] + tags
    client = new_client
    event = new_event(message_text, "Vindicia Select #{message_title}", alert_type, tags)

    client.emit_event event
  end
end
