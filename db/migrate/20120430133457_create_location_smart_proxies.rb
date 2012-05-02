class CreateLocationSmartProxies < ActiveRecord::Migration
  def self.up
    create_table :location_smart_proxies do |t|
      t.integer :location_id
      t.integer :smart_proxy_id

      t.timestamps
    end
  end

  def self.down
    drop_table :location_smart_proxies
  end
end
