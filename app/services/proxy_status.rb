class ProxyStatus
  CONNECTION_ERRORS = [Errno::EINVAL, Errno::ECONNRESET, EOFError, Timeout::Error, Errno::ENOENT,
                       Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, Net::ProtocolError]

  def initialize(proxy, opts = {})
    @proxy = proxy
    @cache_duration = opts[:cache_duration] || 3.minutes
  end

  def proxy_version_api
    @proxy_version_api ||= ProxyAPI::Version.new(:url => proxy.url)
  end

  def proxy_versions
    Rails.cache.fetch(cache_key, :expires_in => cache_duration) do
      fetch_proxy_data do
        proxy_version_api.proxy_versions
      end
    end
  end

  # TODO: extract to another status implementation
  def tftp_server
    Rails.cache.fetch("proxy_#{proxy.id}/tftp_server", :expires_in => cache_duration) do
      fetch_proxy_data do
        ProxyAPI::TFTP.new(:url => proxy.url).bootServer
      end
    end
  end

  def revoke_cache!
    return true if Rails.env.test?
    # As memcached does not support delete_matched, we need to delete each
    Rails.cache.delete(cache_key)
    Rails.cache.delete("proxy_#{proxy.id}/tftp_server")
  end

  def cache_key
    "proxy_#{proxy.id}/versions"
  end
  private

  attr_reader :proxy, :cache_duration, :api

  def fetch_proxy_data &block
    begin
      yield
    rescue *CONNECTION_ERRORS => exception
      raise ::Foreman::WrappedException.new exception, N_("Unable to connect to smart proxy")
    end
  end
end
