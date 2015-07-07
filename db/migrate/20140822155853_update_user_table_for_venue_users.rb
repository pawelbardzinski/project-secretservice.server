class UpdateUserTableForVenueUsers < ActiveRecord::Migration
  def up
    remove_column :users, :usertype
    add_column :users, :role, :int
    add_column :users, :venue_id, :int, null:true
    add_index :users,:venue_id

    execute <<-SQL
      update users SET role = 1 where id>0
    SQL

  end
  def down
    add_column :users, :usertype,:string, limit: 20,default: :Customer
    remove_index :users,:venue_id
    remove_column :users, :role, :int,default:1
    remove_column :users, :venue_id, :int, null:true

  end
end
