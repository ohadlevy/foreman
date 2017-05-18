class Hosts::PowerStatusController < ApplicationController
  include ActionController::Live

  FILTERS = [:require_login, :session_expiry, :update_activity_time, :set_taxonomy, :authorize]
  skip_before_action(*FILTERS, only: :index)
  before_action :find_hosts, only: :index

  def index
    response.headers['Content-Type'] = 'text/event-stream'
    @hosts.each do |host|
      status = PowerManager::State.status(host)
      response.stream.write(status.to_json + "\n")
    end
    response.stream.close
  end

  private
  def find_hosts
    return not_found if params[:ids].empty?
    @hosts = Host.where(id: params[:ids])
    return not_found unless @hosts.any?
  end
end
