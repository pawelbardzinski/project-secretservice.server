class AddPasswordResetToUser < ActiveRecord::Migration
  def change
    add_column :users, :password_reset_token, :text
    add_column :users, :password_expires_after , :datetime
  end
end
