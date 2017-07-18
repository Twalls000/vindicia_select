require 'test_helper'

class C2kTransControllerTest < ActionController::TestCase

  setup do
    @controller = Api::C2kTransController.new
    @dashboard1 =
    {
      gci_unit: "PHX",
      pub_code: "AR",
      account_number: "1421",
      batch_date: "20161102",
      batch_id: "RC1102001",
      amount: "35",
      currency: "USD",
      division_number: "254386",
      merchant_transaction_id: "GN-RC1102001-20161102-0001329-1120",
      select_transaction_id: "",
      subscription_id: "GN00013221120",
      subscription_start_date: "",
      previous_billing_date: "",
      previous_billing_count: "",
      customer_id: "0000013221120",
      credit_card_account_hash: "",
      credit_card_expiration_date: "2018-05-06",
      account_holder_name: "Houman Ghavami",
      billing_address_line1: "6064 Donna Court",
      billing_address_line2: "",
      billing_address_line3: "",
      billing_addr_city: "Rohnert Park",
      billing_address_county: "US",
      billing_address_district: "CA",
      billing_address_postal_code: "94928",
      affiliate_id: "",
      affiliate_sub_id: "",
      billing_statement_identifier: "",
      auth_code: "522",
      avs_code: "18",
      cvn_code: "",
      name_values: "",
      payment_method_id: "1120-GN-0001344-038085",
      declined_timestamp: DateTime.now,
      charge_status: "Failed",
    }
  end

  test "should post create" do
    request.headers['HTTP_API_KEY'] = GciSimpleEncryption.decrypt_hex(ENV['VINDICIA_SELECT_API_KEY'])
    options = {
      transaction: @dashboard1,
    }
    post :create, options
    assert_response :success
  end

end
