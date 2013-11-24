class NoticesController < ApplicationController
  skip_before_filter :authorize, :only => :destroy

  def index
    @notices = Notice.all
    render :index, :layout => !ajax?
  end

  def destroy
    @notice = Notice.find(params[:id])
    @notice.destroy_notice
    redirect_to :back
  end
end
