class MoveProxyConnectionsToSmartProxyConnections < ActiveRecord::Migration
  def up
    features = Feature.all

    dhcp = features.detect { |f| f.name == "DHCP" }
    Subnet.where.not(dhcp_id: nil).each do |subnet|
      ProxyConnection.create!(:managed => subnet, :feature => dns, :smart_proxy_id => subnet.dhcp_id)
    end

    dns = features.detect { |f| f.name == "DNS" }
    Domain.where.not(:dns_id => nil).each do |domain|
      ProxyConnection.create!(:managed => domain, :feature => dns, :smart_proxy_id => domain.dns_id)
    end

    puppet = features.detect { |f| f.name == "Puppet" }
    Host.where.not(puppet_proxy_id: nil).find_in_batches do |hosts|
      hosts.each do |host|
        ProxyConnection.create!(:managed => host, :feature => puppet, :smart_proxy_id => host.puppet_proxy_id)
      end
    end

    Hostgroup.where.not(puppet_proxy_id: nil).find_in_batches do |hostgroups|
      hostgroups.each do |hostgroup|
        ProxyConnection.create!(:managed => hostgroup, :feature => puppet, :smart_proxy_id => hostgroup.puppet_proxy_id)
      end
    end

    puppet_ca= features.detect { |f| f.name == "Puppet CA" }

    Host.where.not(puppet_ca_proxy_id: nil).find_in_batches do |hosts|
      hosts.each do |host|
        ProxyConnection.create!(:managed => host, :feature => puppet_ca, :smart_proxy_id => host.puppet_ca_proxy_id)
      end
    end


    Hostgroup.where.not(puppet_ca_proxy_id: nil).find_in_batches do |hostgroups|
      hostgroups.each do |hostgroup|
        ProxyConnection.create!(:managed => hostgroup, :feature => puppet_ca, :smart_proxy_id => hostgroup.puppet_ca_proxy_id)
      end
    end

    realms = features.detect { |f| f.name == "Realm" }

    Realm.where.not(:realm_proxy_id => nil).each do |realm|
      ProxyConnection.create!(:managed => realm, :feature => realms, :smart_proxy_id => realm.realm_proxy_id)
    end

    remove_column :subnets, :dhcp_id
    remove_column :domains, :dns_id
    remove_columns :hosts, :puppet_proxy_id, :puppet_ca_proxy_id
    remove_columns :hostgroups, :puppet_proxy_id, :puppet_ca_proxy_id
    remove_column :realms, :realm_proxy_id
  end

  def down
    add_column :subnets, :dhcp_id, :integer
    add_column :domains, :dns_id, :integer
    add_column :hosts, :puppet_proxy_id, :integer
    add_column :hosts, :puppet_ca_proxy_id, :integer
    add_column :hostgroups, :puppet_proxy_id, :integer
    add_column :hostgroups, :puppet_ca_proxy_id, :integer
    add_column :realms, :realm_proxy_id, :integer
    ProxyConnection.includes(:feature).find_in_batches do |connections|
      connections.each do |connection|
        attribute = case connection.feature.name
                      when 'DHCP'
                        :dhcp_id
                      when 'DNS'
                        :dns_id
                      when 'Puppet'
                        :puppet_proxy_id
                      when 'Puppet CA'
                        :puppet_proxy_id
                      when 'Realm'
                        :realm_proxy_id
                    end
        connection.managed.update_columns(attribute => connection.smart_proxy_id)
      end
    end
    drop_table :proxy_connections
  end

end
