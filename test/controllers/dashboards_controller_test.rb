require 'test_helper'

class DashboardsControllerTest < ActionController::TestCase
  setup do
    @dashboard = []
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:dashboards)
  end


  test "should show dashboard" do
  end


end
