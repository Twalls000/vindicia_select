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
    test "workflow should initialize correctly" do
      assert @trans.entry?
    end
    test "workflow states" do
      assert_equal [:entry, :processing, :completed], DeclinedCreditCardBatch.aasm.states.map(&:name)
    end
    test "workflow events" do
      assert_equal [:ready_to_process, :done_processing], DeclinedCreditCardBatch.aasm.events.map(&:name)
    end
    test "workflow permitted based on entry state" do
      assert_equal [:ready_to_process], @trans.aasm.events(:permitted => true).map(&:name)
    end
    test "workflow permitted based on processing state" do
      @trans.ready_to_process
      assert_equal [:done_processing], @trans.aasm.events(:permitted => true).map(&:name)
    end
    test "workflow not permitted based on completed state" do
      @trans.ready_to_process
      @trans.done_processing
      assert_equal [], @trans.aasm.events(:permitted => true).map(&:name)
    end
  end
end
