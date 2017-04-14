class JobBase < ActiveJob::Base
  around_perform do |job, block|
    Rails.logger.warn("Starting the #{self.class.name} #{Time.now}")

    begin
      block.call
    rescue => e
      DataDog.send_event(
        "#{e.class} - #{e.message}:\n#{e.backtrace.join("\n")}",
        "#{self.class.name} failed",
        "error",
        ["delayed_job"]
      )

      Rails.logger.error("Error performing #{self.class.name}:\n#{e.backtrace}")
      raise e
    end

    Rails.logger.warn("Completing the #{self.class.name} #{Time.now}")
  end

  def perform; end
end
