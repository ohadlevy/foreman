class CreateLocationSubnet < ActiveRecord::Migration
  def self.up
    create_table :location_subnets do |t|
      t.integer :location_id
      t.integer :subnet_id

      t.timestamps
    end
  end

  def self.down
    drop_table :location_subnets
  end
end
