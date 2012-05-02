class CreateLocationComputeResources < ActiveRecord::Migration
  def self.up
    create_table :location_compute_resources do |t|
      t.integer :location_id
      t.integer :compute_resource_id

      t.timestamps
    end
  end

  def self.down
    drop_table :location_compute_resources
  end
end
