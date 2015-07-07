class AddAuthTokenToUsers < ActiveRecord::Migration
  def change
    add_column :users, :auth_token, :text
    add_column :users, :token_expiration, :datetime
  end
end
