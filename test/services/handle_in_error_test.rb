require 'test_helper'

class HandleInErrorTest < ActiveJob::TestCase
  include ActiveJob::TestHelper

  def setup
    @trans = declined_credit_card_transactions(:handle_in_error)
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
