class LocationMedium < ActiveRecord::Base
  belongs_to :medium
  belongs_to :location
  validates_uniqueness_of :location_id, :scope => :medium_id
end
