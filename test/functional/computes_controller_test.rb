require 'test_helper'

class ComputesControllerTest < ActionController::TestCase
  setup do
    @compute = computes(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:computes)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create compute" do
    assert_difference('Compute.count') do
      post :create, :compute => @compute.attributes
    end

    assert_redirected_to compute_path(assigns(:compute))
  end

  test "should show compute" do
    get :show, :id => @compute.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @compute.to_param
    assert_response :success
  end

  test "should update compute" do
    put :update, :id => @compute.to_param, :compute => @compute.attributes
    assert_redirected_to compute_path(assigns(:compute))
  end

  test "should destroy compute" do
    assert_difference('Compute.count', -1) do
      delete :destroy, :id => @compute.to_param
    end

    assert_redirected_to computes_path
  end
end
