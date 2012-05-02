class CreateHwProfiles < ActiveRecord::Migration
  def self.up
    create_table :hw_profiles do |t|
      t.integer :compute_resource_id
      t.string :compute_resource_template_id
      t.text :vm_attributes

      t.timestamps
    end
  end

  def self.down
    drop_table :hw_profiles
  end
end
