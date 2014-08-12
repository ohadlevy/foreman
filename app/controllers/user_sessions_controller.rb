class UserSessionsController < ApplicationController
  before_filter :clear_current_user, :only => [:new, :create]
  skip_before_filter :require_login, :authorize, :session_expiry, :update_activity_time, :set_taxonomy, :set_gettext_locale_db, :only => [:new, :create, :destroy]

  # login form
  def new
    if params[:status] && params[:status] == 401
      render :layout => 'login', :status => params[:status]
    else
      render :layout => 'login'
    end
  end

  # login
  def create
    backup_session_content { reset_session }
    intercept = SSO::FormIntercept.new(self)
    if intercept.available? && intercept.authenticated?
      user = intercept.current_user
    else
      user = User.try_to_login(params[:login]['login'].downcase, params[:login]['password'])
    end
    if user.nil?
      #failed to authenticate, and/or to generate the account on the fly
      error _("Incorrect username or password")
      redirect_to login_users_path
    else
      #valid user
      login_user(user)
    end

    @user_session = UserSession.new(params[:user_session])
    if @user_session.save
      process_success
    else
      process_error
    end
  end

  # logout
  def destroy
    @user_session = UserSession.find(params[:id])
    if @user_session.destroy
      process_success
    else
      process_error
    end
  end

  private
  def clear_current_user
    User.current = nil
  end

end
