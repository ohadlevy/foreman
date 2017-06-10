class PersonalAccessTokensController < ApplicationController
  include Foreman::Controller::Parameters::PersonalAccessToken
  include Foreman::Controller::UserAware
  include Foreman::Controller::ActionPermissionDsl

  before_action :find_resource, :only => [:revoke]

  define_action_permission 'revoke', :revoke

  def revoke
    if @personal_access_token.revoke!
      process_success :success_redirect => edit_user_path(@user, :anchor => "personal_access_tokens"), :success_msg => _("Successfully revoked Personal Access Token.")
    else
      process_error
    end
  end
end
