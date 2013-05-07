module BmcHelper
  def bmc_available?
    ipmi = @host.bmc_nic
    return false if ipmi.empty?
    ipmi.password.present? && ipmi.username.present? && ipmi.provider == 'IPMI'
  end

  def ipmi_available?
    begin
      timeout(15) do
        @host.bmc_proxy.providers
        true
      end
    rescue Timeout::Error
      false
    end
  end

  def power_status s
    if s.downcase == 'on'
      "<span class='label label-success'>On</span>".html_safe
    else
      "<span class='label'>Off</span>".html_safe
    end
  end

  def power_actions
    controller_options = { :action => "ipmi_power", :id => @host }

    action_buttons(display_link_if_authorized("On", controller_options.merge(:ipmi_action => 'on'),
                                              :confirm => "Are you sure?", :method => :put),
                   display_link_if_authorized("Off", controller_options.merge(:ipmi_action => 'off'),
                                              :confirm => "Are you sure?", :method => :put),
                   display_link_if_authorized("Cycle", controller_options.merge(:ipmi_action => 'cycle'),
                                              :confirm => "Are you sure?", :method => :put),
                   display_link_if_authorized("Soft", controller_options.merge(:ipmi_action => 'soft'), :confirm => "Are you sure?", :method => :put))
  end

  def boot_actions
    controller_options = { :action => "ipmi_boot", :id => @host }

    action_buttons("Select device",
                   display_link_if_authorized("Disk", controller_options.merge(:ipmi_device => 'disk'),
                                              :confirm => "Are you sure?", :method => :put),
                   display_link_if_authorized("Cdrom", controller_options.merge(:ipmi_device => 'cdrom'),
                                              :confirm => "Are you sure?", :method => :put),
                   display_link_if_authorized("Pxe", controller_options.merge(:ipmi_device => 'pxe'),
                                              :confirm => "Are you sure?", :method => :put),
                   display_link_if_authorized("Bios", controller_options.merge(:ipmi_device => 'bios'), :confirm => "Are you sure?", :method => :put))
  end
end
