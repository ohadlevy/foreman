class HostClass < ActiveRecord::Base
  audited :associated_with => :host
  belongs_to :host
  belongs_to :puppetclass

  validates_presence_of :host_id, :puppetclass_id
  validates_uniqueness_of :host_id, :scope => :puppetclass_id

  def name
    "#{host} - #{puppetclass}"
  end
end
