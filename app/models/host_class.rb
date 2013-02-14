class HostClass < ActiveRecord::Base
  audited :associated_with => :host
  belongs_to :host, :class_name => "Host::Managed"
  belongs_to :puppetclass

  validates_presence_of :host_id, :puppetclass_id

  def name
    "#{host} - #{puppetclass}"
  end
end
