require 'test_helper'

class HandleInErrorTest < ActiveJob::TestCase
  include ActiveJob::TestHelper

  class Handle < HandleInErrorTest
    # Tests
  end
end
