module PowerManager
  class State
    TIMEOUT=3
    HOST_POWER = {
      :on =>  { :state => 'on', :title => N_('On') },
      :off => { :state => 'off', :title => N_('Off') },
      :na =>  { :state => 'na', :title => N_('N/A') }
    }.freeze

    def self.status(host)
      new(host).power_state
    end

    def initialize(host)
      @host = host
      # default state no NA
      @result = {:id => host.id}.merge(host_power_state(:na))
    end

    def power_state
      if host.supports_power?
        power_ping
      else
        @result[:statusText] = _('Power operations are not enabled on this host.')
      end

      result
    rescue => e
      Foreman::Logging.exception("Failed to fetch power status", e)
      @result.merge!(host_power_state(:na))
      @result[:statusText] = _("Failed to fetch power status: %s") % e
      result
    end

    private
    attr_reader :host, :result

    def power_ping
      Timeout.timeout(TIMEOUT) do
        @result.merge!(host_power_state(host.supports_power_and_running? ? :on : :off))
      end
      result
    rescue Timeout::Error
      logger.debug("Failed to retrieve power status for #{host} within #{timeout} seconds.")
      result[:statusText] = n_("Failed to retrieve power status for %{host} within %{timeout} second.",
      "Failed to retrieve power status for %{host} within %{timeout} seconds.", timeout) % {:host => host, :timeout => timeout}
      result
    end

    def host_power_state(key)
      HOST_POWER[key].merge(:title => _(HOST_POWER[key][:title]))
    end

  end
end
