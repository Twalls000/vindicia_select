require 'test_helper'

class HandleInErrorTest < ActiveJob::TestCase
  include ActiveJob::TestHelper

  def setup
    @trans = declined_credit_card_transactions(:handle_in_error)
  end

  class Handle < HandleInErrorTest
    # Tests
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
