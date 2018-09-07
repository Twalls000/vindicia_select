require 'test_helper'

class AppConfigsControllerTest < ActionController::TestCase
  setup do
    AppConfig.delete_all
    @app_config = AppConfig.new(key: "MONTHLY_SUMMARY_REPORT_RECIPIENTS")
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:app_configs)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create app_config" do
    assert_difference('AppConfig.count') do
      post :create, app_config: { key: @app_config.key, value: @app_config.value }
    end

    assert_redirected_to app_config_path(assigns(:app_config))
  end

  test "should show app_config" do
    @app_config.save
    get :show, id: @app_config
    assert_response :success
  end

  test "should get edit" do
    @app_config.save
    get :edit, id: @app_config
    assert_response :success
  end

  test "should update app_config" do
    @app_config.save
    patch :update, id: @app_config, app_config: { key: @app_config.key, value: @app_config.value }
    assert_redirected_to app_config_path(assigns(:app_config))
  end

  test "should destroy app_config" do
    @app_config.save
    assert_difference('AppConfig.count', -1) do
      delete :destroy, id: @app_config
    end

    assert_redirected_to app_configs_path
  end
end
