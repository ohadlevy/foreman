class CreateLocationMedia < ActiveRecord::Migration
  def self.up
    create_table :location_media do |t|
      t.integer :location_id
      t.integer :medium_id

      t.timestamps
    end
  end

  def self.down
    drop_table :location_media
  end
end
