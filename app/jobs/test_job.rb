class TestJob < ActiveJob::Base
  queue_as :default

  def perform
    sleep 60
  end
end
