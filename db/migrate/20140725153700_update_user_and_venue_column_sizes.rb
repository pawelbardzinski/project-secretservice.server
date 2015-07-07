class UpdateUserAndVenueColumnSizes < ActiveRecord::Migration
  def change
    change_column :users, :firstname, :string, limit: 30
    change_column :users, :lastname, :string, limit: 30
    change_column :users, :email, :string, limit: 100
    change_column :users, :mobile, :string, limit: 20
    change_column :users, :usertype, :string, limit: 20
    change_column :venues, :name, :string, limit: 100
    change_column :venues, :address_line_1, :string, limit: 100
    change_column :venues, :address_line_2, :string, limit: 100
    change_column :venues, :city, :string, limit: 100
    change_column :venues, :state, :string, limit: 10
    change_column :venues, :zip_code, :string, limit: 10
    change_column :venues, :country, :string, limit: 10
  end
end