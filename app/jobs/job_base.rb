class JobBase < ActiveJob::Base
  around_perform do |job, block|
    Rails.logger.warn("Starting the #{self.class.name} #{Time.now}")

    begin
      block.call
    rescue => e
      # Send email
      Rails.logger.error("Error performing #{self.class.name}: ")
      raise e
    end

    Rails.logger.warn("Completing the #{self.class.name} #{Time.now}")
  end

  def perform; end
end
