module BmcHelper

  def power_status s
    if s.downcase == 'on'
      "<span class='label label-success'>#{_('On')}</span>".html_safe
    else
      "<span class='label'>#{_('Off')}</span>".html_safe
    end
  end

  def power_actions
    action_buttons(
      BMCPowerManager::SUPPORTED_ACTIONS.map do |action|
        display_link_if_authorized(_(action.to_s.capitalize), { :action => "power", :id => @host, :power_action => action},
                                   :confirm => _('Are you sure?'), :method => :put)
      end
    )
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
                   display_link_if_authorized(_('BIOS'), controller_options.merge(:ipmi_device => 'bios'),
                                              :confirm => confirm, :method => :put))
  end
end
