class Image < ActiveRecord::Base
  belongs_to :operatingsystem
  belongs_to :compute_resource
  belongs_to :architecture
  validates_presence_of :username
  validates_presence_of :uuid
  validates_uniqueness_of :uuid, :scope => :compute_resource_id
  validates_presence_of :operatingsystem_id, :compute_resource_id, :architecture_id

  scoped_search :on => [:name, :username], :complete_value => true
  scoped_search :in => :compute_resources, :on => :name, :complete_value => :true, :rename => "compute_resource"
end
