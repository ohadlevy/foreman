class Location < ActiveRecord::Base
  validates_presence_of :name
  validates_uniqueness_of :name

  has_many :location_medium, :dependent => :destroy
  has_many :media, :through => :location_medium
  has_many :location_smart_proxies, :dependent => :destroy
  has_many :smart_proxies, :through => :location_smart_proxies
  has_many :location_subnets, :dependent => :destroy
  has_many :subnets, :through => :location_subnets
  has_many :location_compute_resources, :dependent => :destroy
  has_many :compute_resources, :through => :location_compute_resources

  scoped_search :on => :name, :complete_value => true

  def to_param
    name
  end
end
