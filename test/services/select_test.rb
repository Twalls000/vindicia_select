require 'test_helper'

class SelectTest < ActiveSupport::TestCase
  def setup
    @transactions = Array.new(10, MiniTest::Mock.new)
  end

  def teardown
    @transactions.each { |t| t.verify }
  end

  class BillTransactions < SelectTest
    test 'transactions are sent as Vindicia hashes' do
      @transactions.each { |t| t.expect(:vindicia_fields, true) }
      call_args = ->(method_name, parameters){
        assert_equal({ transactions: Array.new(10, true) }, parameters)
      }
      Select.stub(:call, call_args) do
        Select.bill_transactions @transactions
      end
    end

    test 'the call method is called properly' do
      @transactions.each { |t| t.expect(:vindicia_fields, true) }
      call_args = ->(method_name, parameters){
        assert_equal :bill_transactions, method_name
        assert_equal({ transactions: Array.new(10, true) }, parameters)
      }
      Select.stub(:call, call_args) do
        Select.bill_transactions @transactions
      end
    end

    test 'can handle a single transaction or an array' do
      @transactions.each { |t| t.expect(:vindicia_fields, true) }

      Select.stub(:call, true) do
        Select.bill_transactions @transactions
      end

      trans = MiniTest::Mock.new
      trans.expect(:vindicia_fields, true)

      Select.stub(:call, true) do
        Select.bill_transactions trans
      end
      trans.verify
    end
  end

  class FetchBillingResults < SelectTest
    test 'converts timestamps to vindicia format and calls' do
      timestamp = 2.days.ago
      end_timestamp = DateTime.now

      call_args = ->(method, params) {
        assert_equal :fetch_billing_results, method
        assert_equal({ timestamp: Select.date_to_vindicia(timestamp), end_timestamp: nil, page: 0, page_size: 50 }, params)
      }

      Select.stub(:call, call_args) do
        Select.fetch_billing_results timestamp
      end

      call_args = ->(method, params) {
        assert_equal :fetch_billing_results, method
        assert_equal({ timestamp: Select.date_to_vindicia(timestamp), end_timestamp: Select.date_to_vindicia(end_timestamp), page: 0, page_size: 50 }, params)
      }

      Select.stub(:call, call_args) do
        Select.fetch_billing_results timestamp, end_timestamp
      end
    end
  end

  class Call < SelectTest
    test 'calls Vindicia::Connection.call' do
      call_args = ->(class_name, method_name, parameters){
        assert_equal "Select", class_name
        assert_equal :method, method_name
        assert_equal({ params: "vindicia" }, parameters)
      }

      Vindicia::Connection.stub(:call, call_args) do
        Select.stub(:response_handler, true) do
          Select.call(:method, { params: "vindicia" })
        end
      end
    end

    test 'sends the response to the response handler' do
      call_args = ->(response, default){
        assert_equal "response", response
        assert_equal [], default
      }

      Vindicia::Connection.stub(:call, "response") do
        Select.stub(:response_handler, call_args) do
          Select.call(:method, {})
        end
      end
    end

    test 'sends a different default depending on the method being called' do
      call_args = ->(response, default){
        assert_equal true, default
      }

      Vindicia::Connection.stub(:call, "response") do
        Select.stub(:response_handler, call_args) do
          Select.call(:bill_transactions, {})
        end
      end

      call_args = ->(response, default){
        assert_equal [], default
      }

      Vindicia::Connection.stub(:call, "response") do
        Select.stub(:response_handler, call_args) do
          Select.call(:fetch_billing_results, {})
        end
      end
    end
  end

  class DateToVindicia < SelectTest
    test 'converts date to Vindicia format' do
      date = "July 2, 1990 13:29:00 -0800".to_datetime

      assert_equal "1990-07-02T13:29:00-08:00", Select.date_to_vindicia(date)
    end
  end

  class ConvertGCICCExpirationDateToVindicia < SelectTest
    test 'converts credit card expiration date to Vindicia format' do
      assert_equal "200903", Select.convert_gci_cc_expiration_date_to_vindicia(Date.parse("March 10 2009"))
    end
  end

  class ResponseHandler < SelectTest
    # Tests
  end
end
