require 'test_helper'

class MarketPublicationTest < ActiveSupport::TestCase
  def setup
    DeclinedCreditCard.on_db("9999")
    @market_publication = market_publications(:one)
    @new_mp = MarketPublication.new(pub_code: "US", gci_unit: "1234", batch_date: Date.today, declined_credit_card_batch_size: 500, vindicia_batch_size: 500)
  end

  def teardown
    @new_mp.destroy
  end

  class OnCreation < MarketPublicationTest
    test "declined credit card batch keys are set and are taken from a declined credit card" do
      return_value = [DeclinedCreditCard.new(batch_id: "1234", batch_date: 1.year.ago.strftime("%Y%m%d"), account_number: 12345)]

      DeclinedCreditCard.stub(:first_record_by_date, return_value) do
        @new_mp.save
        batch_keys = return_value.first.batch_keys
        batch_keys[:pub_code] = @new_mp.pub_code

        assert_equal batch_keys, @new_mp.declined_credit_card_batch_keys
      end
    end

    test "pub code is added to declined credit card batch keys" do
      return_value = [DeclinedCreditCard.new(batch_id: "1234", batch_date: 1.year.ago.strftime("%Y%m%d"), account_number: 12345)]

      DeclinedCreditCard.stub(:first_record_by_date, return_value) do
        @new_mp.save

        assert_equal "US", @new_mp.declined_credit_card_batch_keys[:pub_code]
      end
    end
  end

  class TestAllMethod < MarketPublicationTest
    test "ok" do
      assert_equal true, @market_publication.valid?
    end
    test "not ok gci unit and pub code" do
      @market_publication.gci_unit = "999"
      @market_publication.pub_code = "GN"
      assert_not @market_publication.valid?
      @market_publication.gci_unit = "9999"
      @market_publication.pub_code = "G"
      assert_not @market_publication.valid?
    end
    test "not ok uniqueness" do
      mkt = MarketPublication.new(@market_publication.attributes.except("id"))
      assert_not mkt.valid?
    end
  end
end
