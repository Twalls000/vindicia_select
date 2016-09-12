require 'test_helper'

class DeclinedCreditCardTransactionTest < ActiveSupport::TestCase
  def setup
    @trans = DeclinedCreditCardTransaction.new
  end

  class OnInitialize < DeclinedCreditCardTransactionTest
    test "defaults are set before save" do
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
    test "workflow should transition from entry to pending" do
      @trans.sent_to_vindicia!
      assert @trans.pending?
    end
    test "workflow should transition from entry to in_error" do
      @trans.mark_in_error!
      assert @trans.in_error?
    end
    test "workflow states" do
      assert_equal [:entry, :pending, :in_error], DeclinedCreditCardTransaction.aasm.states.map(&:name)
    end
  end
end
