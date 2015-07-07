class CreateOrders < ActiveRecord::Migration
  def change
    create_table :orders do |t|
      t.integer :user_id
      t.integer :venue_id
      t.string :order_status
      t.integer :payment_option_id

      t.timestamps
    end
    add_index :orders,:user_id
    add_index :orders,[:venue_id,:order_status]
  end
end
