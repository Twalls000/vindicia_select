require 'test_helper'

class DeclinedCreditCardTransactionTest < ActiveSupport::TestCase
  def setup
    @trans = DeclinedCreditCardTransaction.new
  end

  class OnInitialize < DeclinedCreditCardTransactionTest
    test "defaults are set before save" do
      @trans.save
      assert_equal @trans.status, DeclinedCreditCardTransaction::INITIAL_STATUS
      assert_equal @trans.currency, DeclinedCreditCardTransaction::DEFAULT_CURRENCY
      assert_equal @trans.billing_address_country, DeclinedCreditCardTransaction::DEFAULT_COUNTRY
      assert_equal @trans.payment_method_tokenized, DeclinedCreditCardTransaction::DEFAULT_TOKENIZED
    end
  end
end
