class VirtPowerManager < PowerManager
  SUPPORTED_ACTIONS = [:start, :stop, :reboot]
  delegate *SUPPORTED_ACTIONS, :to => :vm

  def initialize(opts = {})
    super(opts)
    begin
      timeout(15) do
        @vm = host.compute_resource.find_vm_by_uuid(host.uuid)
      end
    rescue Timeout::Error
      raise Foreman::Exception.new(N_("Timeout has occurred while communicating to %s"), host.compute_resource)
    rescue => e
      logger.warn "Error has occurred while communicating to #{host.compute_resource}: #{e}"
      logger.debug e.backtrace
      raise Foreman::Exception.new(N_("Error has occurred while communicating to %s: %s"), host.compute_resource, e)
    end
  end

  def state
    vm.reload
    vm.state
  end

  private
  attr_reader :vm
end