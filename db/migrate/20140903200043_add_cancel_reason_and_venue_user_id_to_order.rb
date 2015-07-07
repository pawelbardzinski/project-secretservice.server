class AddCancelReasonAndVenueUserIdToOrder < ActiveRecord::Migration
  def up

    add_column :orders, :venue_user_id, :int
    add_column :orders, :cancel_reason , :string, limit: 200

  end

  def down

    remove_column :orders, :venue_user_id
    remove_column :orders, :cancel_reason
  end
end
