class LocationSmartProxy < ActiveRecord::Base
  belongs_to :location
  belongs_to :smart_proxy
  validates_uniqueness_of :location_id, :scope => :smart_proxy_id
end
