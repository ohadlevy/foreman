class CreateUserSessions < ActiveRecord::Migration
  def change
    create_table :user_sessions do |t|
      t.references :user
      t.time :accessed_at
      t.time :revoked_at
      t.string :ip
      t.string :user_agent
      t.string :key

      t.timestamps
    end
    add_index :user_sessions, :user_id
    add_index :user_sessions, :key
  end
end
