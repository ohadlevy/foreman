module Nic
  class BMC < Managed

    ATTRIBUTES = [:username, :password, :provider]
    attr_accessible *ATTRIBUTES

    PROVIDERS = %w(IPMI)
    validates_inclusion_of :provider, :in => PROVIDERS

    ATTRIBUTES.each do |method|
      define_method method do
        self.attrs ||= { }
        self.attrs[method]
      end

      define_method "#{method}=" do |value|
        self.attrs         ||= { }
        self.attrs[method] = value
      end
    end

    def proxy
      # try to find a bmc proxy in the same subnet as our bmc device
      url   = SmartProxy.bmc_proxies.joins(:subnets).where(['dhcp_id = ? or tftp_id = ?', subnet_id, subnet_id]) if subnet_id
      url ||= SmartProxy.bmc_proxies.first.url
      ProxyAPI::BMC.new({ :host_ip  => ip,
                          :url      => url,
                          :user     => username,
                          :password => password })
    end

  end
end