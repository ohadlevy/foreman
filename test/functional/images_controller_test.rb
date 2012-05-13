require 'test_helper'

class ImagesControllerTest < ActionController::TestCase
  setup do
    @image = images(:one)
    @image.uuid = Foreman.uuid.to_s
  end

  test "should get index" do
    get :index, {}, set_session_user
    assert_response :success
    assert_not_nil assigns(:images)
  end

  test "should get new" do
    get :new, {}, set_session_user
    assert_response :success
  end

  test "should create image" do
    assert_difference('Image.count') do
      post :create, { :image => @image.attributes }, set_session_user
    end

    assert_redirected_to images_path
  end

  test "should show image" do
    get :show, { :id => @image.to_param, :format => "json" }, set_session_user
    assert_response :success
  end

  test "should get edit" do
    get :edit, { :id => @image.to_param }, set_session_user
    assert_response :success
  end

  test "should update image" do
    @image.username = "ec2-user"
    put :update, { :id => @image.to_param, :image => @image.attributes }, set_session_user
    assert_redirected_to images_path
  end

  test "should destroy image" do
    assert_difference('Image.count', -1) do
      delete :destroy, { :id => @image.to_param }, set_session_user
    end

    assert_redirected_to images_path
  end
end
