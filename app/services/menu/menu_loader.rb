Menu::MenuManager.map :admin_menu do |menu|
  menu.item :locations,           :caption => _('Locations') if SETTINGS[:locations_enabled]
  menu.item :organizations,       :caption => _('Organizations') if SETTINGS[:organizations_enabled]
  menu.divider
  if SETTINGS[:login]
    menu.item :auth_source_ldaps,  :caption => _('LDAP authentication')
    menu.item :users,             :caption => _('Users')
    menu.item :usergroups,        :caption => _('User groups')
    menu.item :roles,             :caption => _('Roles')
  end
  menu.divider
  menu.item :bookmarks,           :caption => _('Bookmarks')
  menu.item :settings,            :caption => _('Settings')
  menu.item :about_index,         :caption => _('About')
end

Menu::MenuManager.map :top_menu do |menu|
  menu.sub_menu :monitor_menu,    :caption => _('Monitor') do
    menu.item :dashboard,         :caption => _('Dashboard')
    menu.item :reports,           :caption => _('Reports'),
              :url_hash => {:controller => 'reports', :action => 'index', :search => 'eventful = true'}
    menu.item :statistics,        :caption => _('Statistics')
    menu.item :trends,            :caption => _('Trends')
    menu.item :audits,            :caption => _('Audits')
  end

  menu.sub_menu :hosts_menu,      :caption => _('Hosts') do
    menu.item :hosts,             :caption => _('All hosts')
    menu.item :fact_values,       :caption => _('Facts')
  end

  menu.sub_menu :provision_menu,  :caption => _('Provision') do
    menu.item :architectures,     :caption => _('Architectures')
    menu.item :compute_resources, :caption => _('Compute resources')
    menu.item :domains,           :caption => _('Domains')
    menu.item :models,            :caption => _('Hardware models')
    menu.item :media,             :caption => _('Installation media')
    menu.item :operatingsystems,  :caption => _('Operating systems')
    menu.item :ptables,           :caption => _('Partition tables')
    menu.item :config_templates,  :caption => _('Provisioning templates')
    menu.item :subnets,           :caption => _('Subnets')
  end if SETTINGS[:unattended]

  menu.sub_menu :configure_menu,  :caption => _('Configure') do
    menu.item :environments,      :caption => _('Environments')
    menu.item :common_parameters, :caption => _('Global parameters')
    menu.item :hostgroups,        :caption => _('Host groups')
    menu.item :puppetclasses,     :caption => _('Puppet classes')
    menu.item :lookup_keys,       :caption => _('Smart variables')
    menu.item :smart_proxies,     :caption => _('Smart proxies')
  end

end






