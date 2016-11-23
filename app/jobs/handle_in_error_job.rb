class HandleInErrorJob < ActiveJob::Base
  queue_as :handle_in_error

  def perform(ids)
    HandleInError.handle(ids)
  end
end
