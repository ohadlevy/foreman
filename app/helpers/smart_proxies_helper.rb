module SmartProxiesHelper
  def proxy_actions(proxy, authorizer)
    [ display_link_if_authorized(_("Edit"), hash_for_edit_smart_proxy_path(:id => proxy), :class => 'edit_two_pane'),
      display_delete_if_authorized(hash_for_smart_proxy_path(:id => proxy).merge(:auth_object => proxy, :authorizer => authorizer),
                                  :data => {:confirm => _("Delete %s?") % proxy.name}, :class => 'delete') ]
  end

  def smart_proxy_title_actions(proxy, authorizer)
    actions = [display_link_if_authorized(_("Refresh features"), hash_for_refresh_smart_proxy_path(:id => proxy).
                                                                 merge(:auth_object => proxy, :permission => 'edit_smart_proxies', :authorizer => authorizer), :method => :put)]
    if proxy.has_feature?('Puppet CA')
      actions << [display_link_if_authorized(_("Certificates"), hash_for_smart_proxy_puppetca_index_path(:smart_proxy_id => proxy).
                                                                merge(:auth_object => proxy, :permission => 'view_smart_proxies_puppetca', :authorizer => authorizer))]
      actions << [display_link_if_authorized(_("Autosign"), hash_for_smart_proxy_autosign_index_path(:smart_proxy_id => proxy).
                                                            merge(:auth_object => proxy, :permission => 'view_smart_proxies_autosign', :authorizer => authorizer))]
    end
    if SETTINGS[:unattended] and proxy.has_feature?('DHCP')
      actions << display_link_if_authorized(_("Import subnets"), hash_for_import_subnets_path(:smart_proxy_id => proxy))
    end

    title_actions(
      button_group(
        link_to(_("Back"), smart_proxies_path)
      ),
      select_action_button(_("Select Action"), {}, actions),
      button_group(
        display_link_if_authorized(_("Edit"), hash_for_edit_smart_proxy_path(:id => proxy))
      ),
      button_group(
        display_delete_if_authorized(hash_for_smart_proxy_path(:id => proxy).merge(:auth_object => proxy, :authorizer => authorizer),
                                     :data => {:confirm => _("Delete %s?") % proxy.name}, :class => 'btn-danger')
      )
    )
  end

  def generate_links_for(proxy_sub_model)
    return _("None Found") if proxy_sub_model.empty?
    links = []
    proxy_sub_model.each do |model|
      links << link_to(model.to_label, { :controller => model.class.model_name.plural.downcase, :action => :index, :search => "name = #{model.name}" })
    end
    links.to_sentence
  end

  def refresh_proxy_icon(proxy, authorizer)
    display_link_if_authorized(icon_text("refresh"), hash_for_refresh_smart_proxy_path(:id => proxy).
                                                     merge(:auth_object => proxy, :permission => 'edit_smart_proxies', :authorizer => authorizer), :method => :put)
  end
end
