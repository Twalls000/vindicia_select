require 'test_helper'

class DashboardsControllerTest < ActionController::TestCase
  setup do
    @dashboard = []
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:total_by_batches)
  end

  test "should show dashboard" do
    get :show, { id: "batch" }
    assert_response :success
    get :show, { id: "transaction", gci_unit:"9999" }
    assert_response :success
  end

end
