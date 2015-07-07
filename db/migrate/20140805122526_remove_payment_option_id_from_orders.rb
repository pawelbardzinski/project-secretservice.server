class RemovePaymentOptionIdFromOrders < ActiveRecord::Migration
  def up
    remove_column :orders, :payment_option_id
    add_column :orders, :last_4, :string, limit:4
    add_column :orders, :credit_card_brand, :string,limit:30
  end

  def down
    add_column :orders, :payment_option_id, :integer
    remove_column :orders, :last_4
    remove_column :orders, :credit_card_brand
  end
end
