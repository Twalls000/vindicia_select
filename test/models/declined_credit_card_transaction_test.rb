require 'test_helper'

class DeclinedCreditCardTransactionTest < ActiveSupport::TestCase
  def setup
    @trans = DeclinedCreditCardTransaction.new
  end

  class OnInitialize < DeclinedCreditCardTransactionTest
    test "defaults are set before save" do
      @trans.declined_timestamp = DateTime.now
      @trans.save
      assert_equal @trans.charge_status, DeclinedCreditCardTransaction::INITIAL_CHARGE_STATUS
      assert_equal @trans.currency, DeclinedCreditCardTransaction::DEFAULT_CURRENCY
      assert_equal @trans.billing_address_country, DeclinedCreditCardTransaction::DEFAULT_COUNTRY
      assert_equal @trans.payment_method_tokenized, DeclinedCreditCardTransaction::DEFAULT_TOKENIZED
    end
  end

  class WorkFlow < DeclinedCreditCardTransactionTest
    test "workflow should initialize correctly" do
      assert @trans.entry?
    end
    test "workflow states" do
      assert_equal [:entry, :queued_to_send, :pending, :in_error, :processed,
        :printed_bill, :no_reply, :genesys_error, :error_handled, :sending, :awaiting_send].sort,
        DeclinedCreditCardTransaction.aasm.states.map(&:name).sort
    end
    test "workflow events" do
      assert_equal [:queue_to_vindicia, :send_to_vindicia, :error_sending_to_vindicia,
        :mark_in_error, :captured_funds, :failed_to_capture_funds,
        :failed_to_send_to_genesys, :failed_to_get_reply, :handle_error,
        :sending_to_vindicia, :wait_to_send, :queue_for_send].sort,
        DeclinedCreditCardTransaction.aasm.events.map(&:name).sort
    end
    test "workflow permitted based on entry state" do
      assert_equal [:queue_to_vindicia, :mark_in_error],
        @trans.aasm.events(:permitted => true).map(&:name)
    end
    test "workflow permitted based on pending" do
      @trans.status="pending"
      assert_equal [:captured_funds, :failed_to_capture_funds, :failed_to_get_reply],
        @trans.aasm.events(:permitted => true).map(&:name)
    end
    test "workflow permitted based on sending" do
      @trans.status="sending"
      assert_equal [:send_to_vindicia, :error_sending_to_vindicia],
        @trans.aasm.events(:permitted => true).map(&:name)
    end
    test "workflow permitted based on in error" do
      @trans.status="in_error"
      assert_equal [:handle_error, :wait_to_send, :queue_for_send], @trans.aasm.events(:permitted => true).map(&:name)
    end
    test "workflow permitted based on error handled" do
      @trans.status="error_handled"
      assert_equal [:failed_to_send_to_genesys], @trans.aasm.events(:permitted => true).map(&:name)
    end
    test 'status_update should reflect results from Vindicia' do
      @trans.status = "pending"
      @trans.charge_status = "Captured"
      @trans.status_update
      assert @trans.processed?

      @trans.status = "pending"
      @trans.charge_status = "Something Else"
      @trans.status_update
      assert @trans.printed_bill?
    end
  end

  class SummaryStatus < DeclinedCreditCardTransactionTest
    def setup
      @trans = DeclinedCreditCardTransaction.create declined_timestamp: Date.today.to_datetime
    end

    test "when status in entry, pending, queued_to_send" do
      @trans.status = 'entry'
      @trans.save
      assert_equal @trans.summary_status, 'pending'

      @trans.status = 'pending'
      @trans.save
      assert_equal @trans.summary_status, 'pending'

      @trans.status = 'queued_to_send'
      @trans.save
      assert_equal @trans.summary_status, 'pending'
    end

    test "when status success" do
      @trans.status = 'processed'
      @trans.save
      assert_equal @trans.summary_status, 'success'
    end

    test "when status error" do
      @trans.status = 'in_error'
      @trans.save
      assert_equal @trans.summary_status, 'error'
    end

    test "when status failure" do
      @trans.status = 'printed_bill'
      @trans.save
      assert_equal @trans.summary_status, 'failure'

      @trans.status = 'no_reply'
      @trans.save
      assert_equal @trans.summary_status, 'failure'

      @trans.status = 'failure'
      @trans.save
      assert_equal @trans.summary_status, 'failure'
    end
  end

  class Validations < DeclinedCreditCardTransactionTest
    test "uniqueness_by_merchant_transaction_id_and_year" do
      trans = DeclinedCreditCardTransaction.where(merchant_transaction_id: declined_credit_card_transactions(:validation).merchant_transaction_id).first
      dup_trans = DeclinedCreditCardTransaction.new(trans.attributes.except("id", "year"))

      assert dup_trans.invalid?
      assert trans.valid?
    end
  end
end
