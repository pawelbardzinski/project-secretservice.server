class AddLocationToOrder < ActiveRecord::Migration
  def up
    add_column :orders, :location, :string, limit:100
    remove_column :orders, :section
    remove_column :orders, :row
    remove_column :orders, :seat

  end
  def down
    remove_column :orders, :location
    add_column :orders, :section, :string,limit: 30, null:false
    add_column :orders, :row, :string,limit: 30, null:false
    add_column :orders, :seat, :string,limit: 30, null:false


  end
end
