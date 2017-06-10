class PersonalAccessTokensController < ApplicationController
  include Foreman::Controller::Parameters::PersonalAccessToken
  include Foreman::Controller::SshKeysCommon
  include Foreman::Controller::ActionPermissionDsl

  before_action :find_resource, :only => [:revoke]

  define_action_permission 'revoke', :revoke

  def new
    @personal_access_token = PersonalAccessToken.new
  end

  def create
    @personal_access_token = PersonalAccessToken.new(personal_access_token_params.merge(:user => @user))
    token_value = @personal_access_token.generate_token
    if @personal_access_token.save
      flash[:personal_access_token] = token_value
      process_success :success_redirect => edit_user_path(@user, :anchor => "personal_access_tokens")
    else
      process_error
    end
  end

  def revoke
    if @personal_access_token.revoke!
      process_success :success_redirect => edit_user_path(@user, :anchor => "personal_access_tokens"), :success_msg => _("Successfully revoked Personal Access Token.")
    else
      process_error
    end
  end

  protected

  def convert_expiry_date
    self.params = ActionController::Parameters.new(converted_params)
  end
end
