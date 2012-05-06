class AddTypeToHost < ActiveRecord::Migration
  class Host < ActiveRecord::Base
    belongs_to :hostgroup
    has_many :host_classes, :dependent => :destroy
    has_many :puppetclasses, :through => :host_classes
  end

  def self.up
    add_column :hosts, :type, :string
    Host.reset_column_information

    Host.all.each do |host|
      if host.compute_resource_id
        host.update_attribute(:type, "Node::Provisioned::Virt")
      elsif host.managed? and not host.compute_resource_id
        host.update_attribute(:type, "Node::Provisioned::BareMetal")
      elsif host.puppetclasses.any? or host.hostgroup.puppetclasses.any?
        host.update_attribute(:type, "Node::Managed")
      else
        host.update_attribute(:type, "Node::Monitored")
      end
    end
  end

  def self.down
    remove_column :hosts, :type, :string
  end
end
