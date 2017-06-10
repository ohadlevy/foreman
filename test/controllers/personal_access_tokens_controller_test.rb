require 'test_helper'

class PersonalAccessTokensControllerTest < ActionController::TestCase
  let(:token) { FactoryGirl.create(:personal_access_token)  }
  let(:user) { token.user }

  test 'revoke' do
    put :revoke, {:id => token.id, :user_id => user.id}, set_session_user
    assert_redirected_to edit_user_url(user, :anchor => 'personal_access_tokens')
    assert_equal true, token.reload.revoked?
  end
end
