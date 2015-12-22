class ProxyConnection < ActiveRecord::Base
  belongs_to :smart_proxy
  belongs_to :managed, polymorphic: true
  belongs_to :feature

  validates :smart_proxy_id, :managed_id, :managed_type, :feature_id, :presence => true
end
