class PuppetcaController < ApplicationController

  def index
    find_proxy
    # expire cache if forced
    @puppet_ca.revoke_cache! if params[:expire_cache] == 'true'
    certs         = find_certs
    @certificates = certs.sort.paginate :page => params[:page], :per_page => Setting::General.entries_per_page
  end

  def update
    @proxy = find_proxy(:edit_smart_proxies_puppetca)
    cert   = SmartProxies::PuppetCA.find(@proxy, params[:id])
    if cert.sign
      process_success(:success_redirect => smart_proxy_puppetca_index_path(@proxy, :state => params[:state]),
                      :object_name      => cert.to_s)
    else
      process_error(:redirect => smart_proxy_puppetca_index_path(@proxy))
    end
  end

  def destroy
    @proxy = find_proxy(:destroy_smart_proxies_puppetca)
    cert   = SmartProxies::PuppetCA.find(@proxy, params[:id])
    if cert.destroy
      process_success({ :success_redirect => smart_proxy_puppetca_index_path(@proxy, :state => params[:state]), :object_name => cert.to_s })
    else
      process_error({ :redirect => smart_proxy_puppetca_index_path(@proxy) })
    end
  end

  private

  def find_proxy(permission = :view_smart_proxies_puppetca)
    @proxy     = SmartProxy.authorized(permission).find(params[:smart_proxy_id])
    @puppet_ca = PuppetCAStatus.new(@proxy)
  end

  def find_certs
    case params[:state]
      when 'all'
        @puppet_ca.all
      when ''
        @puppet_ca.find_by_state(%w(valid pending))
      else
        puppet_ca.find_by_state params[:state]
    end
  end
end
