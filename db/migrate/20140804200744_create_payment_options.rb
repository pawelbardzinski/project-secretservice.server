class CreatePaymentOptions < ActiveRecord::Migration
  def change
    create_table :payment_options do |t|
      t.string :last_4, limit: 4
      t.string :credit_card_brand, limit: 30
      t.integer :user_id, null:false

      t.timestamps
    end
  end
end
