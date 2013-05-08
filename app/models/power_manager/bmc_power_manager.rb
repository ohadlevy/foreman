class BMCPowerManager < PowerManager
  SUPPORTED_ACTIONS = [:on, :off, :cycle, :soft]

  def initialize(opts = {})
    super(opts)
    @proxy =  host.bmc_proxy
  end

  def start
    proxy.power(:action => 'on')
  end

  def stop
    proxy.power(:action => 'off')
  end

  def reboot(force = false)
    proxy.power(:action => force ? :cycle : :soft)
  end

  def state
    proxy.power(:action => 'status')
  end

  private
  attr_reader :proxy

end