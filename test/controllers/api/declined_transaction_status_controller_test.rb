require 'test_helper'

class Api::DeclinedTransactionStatusControllerTest < ActionController::TestCase

  def setup
    @controller = Api::DeclinedTransactionStatusController.new
    transaction = DeclinedCreditCardTransaction.new(declined_timestamp: Date.today.to_datetime, gci_unit: MarketPublication::PHOENIX)
    transaction.save
    request.headers['HTTP_API_KEY'] = GciSimpleEncryption.decrypt_hex(ENV['VINDICIA_SELECT_API_KEY'])
  end

  test "should get show" do
    transaction = DeclinedCreditCardTransaction.last
    get :show, id: transaction.id, format: :json

    assert_response :success
  end

  test 'should http-404 unless gci_unit is PHX' do
    txn = DeclinedCreditCardTransaction.last
    txn.update(gci_unit: '999')
    get :show, id: txn.id
    assert_response :not_found
  end
end
