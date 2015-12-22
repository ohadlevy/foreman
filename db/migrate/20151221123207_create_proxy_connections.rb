class CreateProxyConnections < ActiveRecord::Migration
  def change
    create_table :proxy_connections do |t|
      t.references :smart_proxy, index: true
      t.references :managed, polymorphic: true, index: true
      t.references :feature, index: true

      t.timestamps
    end

  end
end
