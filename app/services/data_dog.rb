module DataDog
  DATADOG_API_KEY = ENV["DATADOG_API_KEY"]
  DATADOG_APP_KEY = ENV["VS_DATADOG_APP_KEY"]

  def self.new_client
    Dogapi::Client.new(DATADOG_API_KEY,DATADOG_APP_KEY)
  end
end
