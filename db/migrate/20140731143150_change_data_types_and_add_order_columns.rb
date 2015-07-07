class ChangeDataTypesAndAddOrderColumns < ActiveRecord::Migration
  def up
    change_column :orders, :user_id, :integer, null:false
    change_column :orders, :venue_id, :integer, null:false
    change_column :orders, :order_status, :integer, null:false
    change_column :order_items, :order_id, :integer, null:false
    change_column :order_items, :product_id, :integer, null:false
    change_column :order_items, :price, :float, null:false
    change_column :order_items, :quantity, :integer, null:false

    change_column :users, :firstname, :string, limit: 30,null:false
    change_column :users, :email, :string, limit: 100,null:false
    change_column :users, :mobile, :string, limit: 20,null:false
    change_column :users, :usertype, :string, limit: 20,null:false

    change_column :venues, :name, :string, limit: 100,null:false
    change_column :venues, :address_line_1, :string, limit: 100,null:false
    change_column :venues, :city, :string, limit: 100,null:false
    change_column :venues, :state, :string, limit: 10,null:false
    change_column :venues, :zip_code, :string, limit: 10,null:false

    change_column :products, :name, :string, limit: 30,null:false
    change_column :products, :price, :float ,null:false
    change_column :products, :venue_id, :integer,null:false

    add_column :orders, :section, :string,limit: 30, null:false
    add_column :orders, :row, :string,limit: 30, null:false
    add_column :orders, :seat, :string,limit: 30, null:false

  end
  def down

    change_column :orders, :user_id, :integer
    change_column :orders, :venue_id, :integer
    change_column :orders, :order_status, :integer
    change_column :order_items, :order_id, :integer
    change_column :order_items, :product_id, :integer
    change_column :order_items, :price, :float
    change_column :order_items, :quantity, :integer

    change_column :users, :firstname, :string, limit: 30
    change_column :users, :email, :string, limit: 100
    change_column :users, :mobile, :string, limit: 20
    change_column :users, :usertype, :string, limit: 20

    change_column :venues, :name, :string, limit: 100
    change_column :venues, :address_line_1, :string, limit: 100
    change_column :venues, :city, :string, limit: 100
    change_column :venues, :state, :string, limit: 10
    change_column :venues, :zip_code, :string, limit: 10

    change_column :products, :name, :string, limit: 30
    change_column :products, :price, :float
    change_column :products, :venue_id, :integer

    remove_column :orders, :section
    remove_column :orders, :row
    remove_column :orders, :seat
  end
end
