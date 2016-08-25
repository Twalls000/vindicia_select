require 'test_helper'

class DeclinedCreditCardBatchTest < ActiveSupport::TestCase
  def setup
    @trans = DeclinedCreditCardBatch.new
  end

  class OnInitialize < DeclinedCreditCardBatchTest
    test "defaults are set before save" do
      @trans.save
      assert_equal @trans.status, DeclinedCreditCardBatch::INITIAL_STATUS
      assert_equal @trans.create_start_timestamp.to_date, Date.today
    end
  end

end
