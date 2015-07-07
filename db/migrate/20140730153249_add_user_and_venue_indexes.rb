class AddUserAndVenueIndexes < ActiveRecord::Migration
  def change
    add_index :users,:mobile
    add_index :users,:email, unique: true
    add_index :venues,:name
    add_index :venues,:latitude
    add_index :venues,:longitude
  end
end
