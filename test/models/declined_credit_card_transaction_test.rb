require 'test_helper'

class DeclinedCreditCardTransactionTest < ActiveSupport::TestCase
  def setup
    @trans = DeclinedCreditCardTransaction.new
  end

  class OnInitialize < DeclinedCreditCardTransactionTest
    test "defaults are set before save" do
      @trans.save
      initial_status = DeclinedCreditCardTransaction::INITIAL_STATUS
      default_currency = DeclinedCreditCardTransaction::DEFAULT_CURRENCY

      assert_equal @trans.status,   initial_status
      assert_equal @trans.currency, default_currency
    end
  end
end
