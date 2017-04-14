require 'test_helper'

class DataDogTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  class SendEvent < DataDogTest
    def setup
      @args = {
        msg_text: "Message Text",
        msg_title: "Message Title",
        alert_type: "error",
        tags: ["other_tag"]
      }
    end

    test 'sends an email with the mailer' do
      test_var = false
      mock = MiniTest::Mock.new

      mock.expect(:deliver_now, true)
      test_lambda = ->(*args){
        test_var = true
        mock
      }
      AlertMailer.stub :alert_email, test_lambda do
        DataDog.send_event(*@args.values)
      end

      assert test_var
      assert mock.verify
    end
  end
end
