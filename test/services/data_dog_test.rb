require 'test_helper'

class DataDogTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  class NewClient < DataDogTest
    test 'creates a new instance of Dogapi::Client with the API key' do
      client = DataDog.new_client

      assert_instance_of Dogapi::Client, client
      assert_equal ENV["DATADOG_API_KEY"], client.instance_variable_get(:@api_key)
    end
  end

  class NewEvent < DataDogTest
    def setup
      @args = {
        msg_text: "Message Text",
        msg_title: "Message Title",
        alert_type: "error",
        tags: ["other_tag"]
      }
    end

    test 'creates an Dogapi::Event with the proper arguments' do
      event = DataDog.new_event(*@args.values)

      assert_instance_of Dogapi::Event, event
      @args.each do |var_name,value|
        assert_equal value, event.instance_variable_get("@#{var_name}")
      end
    end
  end

  class SendEvent < DataDogTest
    def setup
      @args = {
        msg_text: "Message Text",
        msg_title: "Message Title",
        alert_type: "error",
        tags: ["other_tag"]
      }
    end

    # This is to make sure that the event is returned, so we can make sure
    # values are set properly
    class Dogapi::Client
      def emit_event(event)
        event
      end
    end

    test 'adds default tags to the tags' do
      event = DataDog.send_event(*@args.values)

      assert_includes event.instance_variable_get(:@tags), "vindicia_select"
      assert_includes event.instance_variable_get(:@tags), "environment:#{Rails.env}"
      assert_includes event.instance_variable_get(:@tags), "other_tag"
    end

    test 'prefixes "Vindicia Select" to the message title' do
      event = DataDog.send_event(*@args.values)

      assert_equal "Vindicia Select #{@args[:msg_title]}", event.instance_variable_get(:@msg_title)
    end

    test 'sends the event to Datadog' do
      client = Minitest::Mock.new
      client.expect :emit_event, true do |event|
        event.is_a? Dogapi::Event
      end

      DataDog.stub(:new_client, client) do
        DataDog.send_event(*@args.values)
      end

      client.verify
    end
  end
end
