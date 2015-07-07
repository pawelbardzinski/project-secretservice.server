class AddVenueIdToPaymentOptions < ActiveRecord::Migration
  def up

    add_column :venues, :allow_membership_payment, :boolean, default:false
    add_column :venues, :allow_credit_card_payment, :boolean, default:true
    add_column :venues, :allow_cash_payment, :boolean, default:true
    add_column :payment_options, :payment_type, :int
    add_column :payment_options, :payment_identifier, :string, limit:32
    add_column :payment_options, :venue_id, :int

    add_column :orders, :payment_type, :int
    add_column :orders, :payment_identifier, :string, limit:32
    add_index :payment_options,:user_id
  end

  def down
    remove_column :venues, :allow_membership_payment
    remove_column :venues, :allow_credit_card_payment
    remove_column :venues, :allow_cash_payment
    remove_column :payment_options, :payment_type
    remove_column :payment_options, :payment_identifier
    remove_column :payment_options, :venue_id
    remove_column :orders, :payment_type
    remove_column :orders, :payment_identifier
    remove_index :payment_options,:user_id
  end
end
