require 'test_helper'

class DeclinedCreditCardBatchTest < ActiveSupport::TestCase
  def setup
    @trans = declined_credit_card_batches(:one)
  end

  class OnInitialize < DeclinedCreditCardBatchTest
    test "defaults are set before save" do
      @trans.save
      assert_equal @trans.create_start_timestamp.to_date, Date.today
    end

    # mandatory for the processes to work
    test "gci_unit is mandatory" do
      @trans.gci_unit = nil
      assert_equal false, @trans.valid?
    end
    test "pub_code is mandatory" do
      @trans.pub_code = nil
      assert_equal false, @trans.valid?
    end
  end

  class WorkFlow < DeclinedCreditCardBatchTest
    test "ensure the workflow is correct" do
      assert_equal true, @trans.new?
    end
  end
end
