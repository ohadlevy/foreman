class PuppetCAStatus < ProxyStatus
  CA_STATES = %w(valid pending revoked)

  def initialize(proxy, opts = {})
    raise ::Foreman::Exception.new(N_('Must specify a Smart Proxy to use')) if proxy.nil?
    @proxy          = proxy
    @cache_duration = opts[:cache_duration] || 3.minutes
    @api            = ProxyAPI::Puppetca.new({ :url => proxy.url })
  end

  def all
    Rails.cache.fetch(cache_key, :expires_in => cache_duration) do

      api.all.map do |name, properties|
        SmartProxies::PuppetCA.new([name.strip, properties['state'], properties['fingerprint'], properties['not_before'], properties['not_after'], self])
      end.compact

    end
  end

  def find(name)
    all.find { |c| c.name == name }
  end

  def find_by_state(state)
    case state
      when String
        all.select { |c| c.state == state }
      when Array
        all.select { |c| state.include?(c.state) }
    end
  end

  def revoke_cache!
    Rails.cache.delete(cache_key)
  end

  def sign name
    api.sign_certificate(name)
  end

  def destroy name
    api.del_certificate(name)
  end
  private

  def cache_key
    "ca_#{proxy.id}"
  end

  attr_reader :proxy, :cache_duration, :api
end