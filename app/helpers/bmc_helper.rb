module BmcHelper
  def bmc_available?
    ipmi = @host.bmc_nic
    return false if ipmi.nil?
    ipmi.password.present? && ipmi.username.present? && ipmi.provider == 'IPMI'
  end

  def power_status s
    if s.downcase == 'on'
      "<span class='label label-success'>#{_('On')}</span>".html_safe
    else
      "<span class='label'>#{_('Off')}</span>".html_safe
    end
  end

  def power_actions
    controller_options = { :action => "ipmi_power", :id => @host }

    confirm = _('Are you sure?')

    action_buttons(display_link_if_authorized(_('On'), controller_options.merge(:ipmi_action => 'on'),
                                              :confirm => confirm, :method => :put),
                   display_link_if_authorized(_('Off'), controller_options.merge(:ipmi_action => 'off'),
                                              :confirm => confirm, :method => :put),
                   display_link_if_authorized(_('Cycle'), controller_options.merge(:ipmi_action => 'cycle'),
                                              :confirm => confirm, :method => :put),
                   display_link_if_authorized(_('Soft'), controller_options.merge(:ipmi_action => 'soft'), :confirm => confirm, :method => :put))
  end

  def boot_actions
    controller_options = { :action => "ipmi_boot", :id => @host }

    confirm = _('Are you sure?')

    action_buttons("Select device",
                   display_link_if_authorized(_('Disk'), controller_options.merge(:ipmi_device => 'disk'),
                                              :confirm => confirm, :method => :put),
                   display_link_if_authorized(_('CDROM'), controller_options.merge(:ipmi_device => 'cdrom'),
                                              :confirm => confirm, :method => :put),
                   display_link_if_authorized(_('PXE'), controller_options.merge(:ipmi_device => 'pxe'),
                                              :confirm => confirm, :method => :put),
                   display_link_if_authorized(_('BIOS'), controller_options.merge(:ipmi_device => 'bios'), :confirm => confirm, :method => :put))
  end
end
