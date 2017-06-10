require 'test_helper'

class PersonalAccessTokensControllerTest < ActionController::TestCase
  let(:token) { FactoryGirl.create(:personal_access_token)  }
  let(:user) { token.user }

  test 'new' do
    get :new, {:user_id => user.id}, set_session_user
    assert_template 'new'
  end

  test 'create_invalid' do
    post :create, {:personal_access_token => {:name => nil}, :user_id => user.id}, set_session_user
    assert_template 'new'
  end

  test 'create_valid' do
    user
    assert_difference 'PersonalAccessToken.count', 1 do
      post :create, {:personal_access_token => { :name => 'dummy'}, :user_id => user.id}, set_session_user
    end
    assert_redirected_to edit_user_url(user, :anchor => 'personal_access_tokens')
  end

  test 'create_valid_with_expiry' do
    user
    assert_difference 'PersonalAccessToken.count', 1 do
      post :create, {:personal_access_token => { :name => 'dummy', :expires_at => '2017-06-16'}, :user_id => user.id}, set_session_user
    end
    assert_redirected_to edit_user_url(user, :anchor => 'personal_access_tokens')
    created_token = PersonalAccessToken.where(:user => user.id, :name => 'dummy').first
    assert_equal true, created_token.expires?
    assert_equal '2017-06-16', created_token.expires_at.to_date.to_s(:db)
  end

  test 'revoke' do
    put :revoke, {:id => token.id, :user_id => user.id}, set_session_user
    assert_redirected_to edit_user_url(user, :anchor => 'personal_access_tokens')
    assert_equal true, token.reload.revoked?
  end
end
