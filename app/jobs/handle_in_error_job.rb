class HandleInErrorJob < ActiveJob::Base
  queue_as :handle_in_error

  def perform(*args)
    # Do something later
  end
end
