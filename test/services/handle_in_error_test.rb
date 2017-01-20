require 'test_helper'

class HandleInErrorTest < ActiveJob::TestCase
  include ActiveJob::TestHelper

  def setup
    @trans = declined_credit_card_transactions(:handle_in_error).dup
    @trans.save
  end

  class Handle < HandleInErrorTest
    class WhenMoreThanOneAuditTrail < Handle
      test 'the transaction is sent to Genesys as failed' do
        @trans.audit_trails.create(event: "Some event")
        @trans.audit_trails.create(event: "Some other event")
        verify = ->(trans){
          assert_equal @trans.id, trans.id
        }

        verify_class_method HandleInError, :send_failed_to_genesys, verify do
          HandleInError.handle([@trans.id])
        end
        trans = DeclinedCreditCardTransaction.find @trans.id
        assert_equal "Failed", trans.charge_status
      end
    end

    class WhenErrorMatchesKnownErrors < Handle
      def status_change(status)
        HandleInError.handle([@trans.id])
        trans = DeclinedCreditCardTransaction.find @trans.id
        assert trans.send("#{status}?".to_sym)
      end

      test 'Failure Errors are sent to Genesys as failed and marked as error_handled' do
        @trans.audit_trails.create(event: HandleInError::FAILURE_ERRORS.sample.to_s)

        status_change "error_handled"
      end

      test 'Retry errors are set as entry' do
        @trans.audit_trails.create(event: HandleInError::RETRY_ERRORS.sample.to_s)

        status_change "entry"
      end

      test 'Pending errors are set as pending' do
        @trans.audit_trails.create(event: HandleInError::PENDING_ERRORS.sample.to_s)

        status_change "pending"
      end
    end

    class WhenErrorIsUnknown < Handle
      def setup
        super
        @trans.audit_trails.create(event: "this is some unknown error")
      end

      def silence_datadog_call
        verify = ->(trans){
          assert_equal @trans.id, trans.id
        }

        DataDog.stub :send_event, true do
          verify_class_method DeclinedCreditCard, :send_transaction, verify do
            HandleInError.handle([@trans.id])
          end
        end
      end

      test 'the transaction is sent to Genesys as failed' do
        silence_datadog_call

        trans = DeclinedCreditCardTransaction.find @trans.id
        assert_equal "Failed", trans.charge_status
      end

      test 'the transaction has error_handled status' do
        silence_datadog_call

        trans = DeclinedCreditCardTransaction.find @trans.id
        assert trans.error_handled?
      end

      test 'a DataDog event is created' do
        verify = ->(msg, title, alert_type, tags){
          ex_msg = "Transaction with ID #{@trans.id}:\n\n#{@trans.audit_trails.map(&:event).join("\n")}"
          ex_title = "Encountered unknown error when handling in_error transaction"
          assert_equal ex_msg, msg
          assert_equal ex_title, title
          assert_equal "error", alert_type
          assert_equal ["handle_in_error"], tags
        }

        verify_class_method DataDog, :send_event, verify do
          HandleInError.stub :send_failed_to_genesys, true do
            HandleInError.handle([@trans.id])
          end
        end
      end
    end
  end

  class MatchesKnownErrors < HandleInErrorTest
    def get_error_type(type)
      "HandleInError::#{type.upcase}_ERRORS".constantize
    end

    def setup
      @error_types = ["pending", "retry", "failure"]
      @errors = @error_types.map do |type|
        get_error_type type
      end
    end

    class Method < MatchesKnownErrors
      test 'returns true if there are matching errors' do
        @errors.each do |error_arr|
          event = error_arr.sample.to_s

          assert HandleInError.matches_known_errors? event, error_arr
        end
      end

      test 'returns false if there are no matching errors' do
        @errors.each do |error_arr|
          event = "not a known error"

          refute HandleInError.matches_known_errors? event, error_arr
        end
      end
    end

    class MatchesKnownErrorTypes < MatchesKnownErrors
      test 'return true if there are matching errors' do
        @error_types.each do |type|
          event = get_error_type(type).sample.to_s

          assert HandleInError.send("matches_known_#{type}_errors?".to_sym, event)
        end
      end

      test 'return false if there are no matching errors' do
        @error_types.each do |type|
          event = "not a known error"

          refute HandleInError.send("matches_known_#{type}_errors?".to_sym, event)
        end
      end
    end
  end

  class SendFailedToGenesys < HandleInErrorTest
    test 'transactions are put in the right state and sent to Genesys' do
      verify_send = ->(transaction){
        assert_equal @trans.object_id, transaction.object_id
        return true
      }

      DeclinedCreditCard.stub :send_transaction, verify_send do
        HandleInError.send_failed_to_genesys(@trans)
      end

      assert_equal "error_handled", @trans.status
    end

    test 'transactions are put in genesys_error status if that happens' do
      DeclinedCreditCard.stub :send_transaction, false do
        HandleInError.send_failed_to_genesys(@trans)
      end

      assert_equal "genesys_error", @trans.status
    end
  end
end
