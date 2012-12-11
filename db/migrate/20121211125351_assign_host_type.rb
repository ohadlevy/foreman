class AssignHostType < ActiveRecord::Migration
  def self.up
    execute "UPDATE hosts set type='ManagedHost'"
  end

  def self.down
    execute "UPDATE hosts set type=''"
  end
end
