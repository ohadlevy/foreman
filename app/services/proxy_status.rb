class ProxyStatus
  HTTP_ERRORS = [Errno::EINVAL, Errno::ECONNRESET, EOFError, Timeout::Error, Errno::ENOENT,
                 Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, Net::ProtocolError]

  def initialize(proxy_id, proxy_url)
    @proxy_id = proxy_id
    @proxy_url = proxy_url
  end

  def proxy_version_api
    @proxy_version_api ||= ProxyAPI::Version.new(:url => @proxy_url)
  end

  def proxy_versions
    Rails.cache.fetch("proxy_#{@proxy_id}/versions", :expires_in => 3.minutes) do
      fetch_proxy_data do
        proxy_version_api.proxy_versions
      end
    end
  end

  def tftp_server
    Rails.cache.fetch("proxy_#{@proxy_id}/tftp_server", :expires_in => 3.minutes) do
      fetch_proxy_data do
        ProxyAPI::TFTP.new(:url => @proxy_url).bootServer
      end
    end
  end

  def delete_cached_versions
    return true if Rails.env.test?
    # As memcached does not support delete_matched, we need to delete each
    Rails.cache.delete("proxy_#{@proxy_id}/versions")
    Rails.cache.delete("proxy_#{@proxy_id}/tftp_server")
  end

  private

  def fetch_proxy_data &block
    begin
      yield
    rescue *HTTP_ERRORS => exception
      raise ::Foreman::WrappedException.new exception, N_("Unable to connect to smart proxy")
    end
  end
end
