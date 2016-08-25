require 'test_helper'

class DeclinedCreditCardTest < ActiveSupport::TestCase
  def setup
    DeclinedCreditCard.on_db("9999")
    @trans = DeclinedCreditCard.new(audit_date:20160101,
      pub_code:"GN", batch_id:"RS100", batch_date:20100101, account_number:1)
  end

  class DeclinedTimestamp < DeclinedCreditCardTest
    test "ensure the timestamp does not error" do
      assert_not_nil @trans.declined_timestamp
    end
    test "ensure the timestamp does error" do
      @trans.audit_date = 20159999
      assert_nil @trans.declined_timestamp
    end
  end

  class MerchantTransactionId < DeclinedCreditCardTest
    test "merchant id is built from field" do
      # Note, the GCI Unit should be first, because it is a Ghost
      assert_equal "9999-GN-RS100-20100101-1", @trans.merchant_transaction_id
    end
  end
end
