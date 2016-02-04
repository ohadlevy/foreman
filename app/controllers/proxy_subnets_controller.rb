class ProxySubnetsController < ApplicationController
  before_filter :find_proxy, :only => [:index, :details]

  def index
    @subnets = @smart_proxy.statuses[:dhcp].subnets
    render :partial => 'smart_proxies/plugins/dhcp'
  rescue Foreman::Exception => e
    process_ajax_error e
  end

  def details
    @details = @smart_proxy.statuses[:dhcp].subnet dhcp_subnet
    render :partial => 'smart_proxies/plugins/dhcp_subnet_details'
  rescue Foreman::Exception => e
    process_ajax_error e
  end

  private

  def find_proxy
    @smart_proxy = SmartProxy.find params[:smart_proxy_id]
  end

  def dhcp_subnet
    { :network => params[:network], :netmask => params[:netmask] }
  end

  def action_permission
    case params[:action]
    when 'details'
      :view
    else
      super
    end
  end
end
