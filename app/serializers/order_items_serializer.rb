class OrderItemsSerializer < ActiveModel::Serializer
  attributes :id, :quantity, :price, :created_at, :venue, :user_full_name,
             :order_status, :product_name

  def venue
    venue_id = object.order.venue_id
    venue_id && venue_id > 0 ? Venue.find(venue_id).name : ""
  end

  def user_full_name
    return "" unless object.order.user
    "#{object.order.user.firstname} #{object.order.user.lastname}"
  end

  def order_status
    object.order.order_status
  end

  def product_name
    object.product.name
  end
end
