class LocationSubnet < ActiveRecord::Base
  belongs_to :location
  belongs_to :subnet
  validates_uniqueness_of :location_id, :scope => :subnet_id
end
