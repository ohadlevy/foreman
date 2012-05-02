class LocationComputeResource < ActiveRecord::Base
  belongs_to :location
  belongs_to :compute_resource
  validates_uniqueness_of :location_id, :scope => :compute_resource_id
end
