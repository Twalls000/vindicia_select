require 'test_helper'

JobBase.send(:define_method, :perform, lambda { |error = false| raise "an error" if error })

class JobBaseTest < ActiveJob::TestCase
  class AroundPerform < JobBaseTest
    class Logging < AroundPerform
      test 'the Rails logger logs the start and end of the job' do
        logger = Minitest::Mock.new Rails.logger
        logger.expect :warn, true do |str|
          assert_match /Starting the JobBase/, str
        end
        logger.expect :warn, true do |str|
          assert_match /Completing the JobBase/, str
        end

        Rails.stub(:logger, logger) do
          JobBase.perform_now
        end

        logger.verify
      end
    end

    class WhenThereIsAnError < AroundPerform
      test 'an event is sent to Datadog' do
        verify_params = ->(msg_text, msg_title, alert_type, tags){
          assert_match /an error/, msg_text
          assert_equal "JobBase failed", msg_title
          assert_equal "error", alert_type
          assert_equal ["delayed_job"], tags
        }
        DataDog.stub :send_event, verify_params do
          JobBase.perform_now(true) rescue true
        end
      end

      test 'the Rails logger logs the issue' do
        logger = Minitest::Mock.new Rails.logger
        logger.expect :error, true do |str|
          assert_match /Error performing JobBase\:/, str
        end

        Rails.stub(:logger, logger) do
          JobBase.perform_now(true) rescue true
        end
      end

      test 'the error is re-raised' do
        assert_raises "an error" do
          JobBase.perform_now(true)
        end
      end
    end
  end
end
