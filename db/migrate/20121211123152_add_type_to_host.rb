class AddTypeToHost < ActiveRecord::Migration
  def self.up
    add_column :hosts, :type, :string
  end

  def self.down
    remove_column :hosts, :type
  end
end
