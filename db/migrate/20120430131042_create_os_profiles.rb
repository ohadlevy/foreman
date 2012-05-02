class CreateOsProfiles < ActiveRecord::Migration
  def self.up
    create_table :os_profiles do |t|
      t.integer :architecture_id
      t.integer :operatingsystem_id
      t.integer :ptable_id
      t.string :root_pw_hash

      t.timestamps
    end
  end

  def self.down
    drop_table :os_profiles
  end
end
