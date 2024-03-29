class OrderItemsSerializer < ActiveModel::Serializer
  attributes :id, :quantity, :total_price, :created_at, :venue, :user_full_name,
             :order_status, :product_name, :location, :order_id

  def venue
    venue_id = object.order.venue_id
    venue_id && venue_id > 0 ? Venue.find(venue_id).name : ''
  end

  def user_full_name
    return '' unless object.order.user
    "#{object.order.user.firstname} #{object.order.user.lastname}"
  end

  def order_status
    Order::STATUSES.values.detect { |item| item[:id] == object.order.order_status }[:name]
  end

  def product_name
    object.product.name
  end

  def total_price
    object.price * object.quantity
  end

  def location
    object.order.location
  end

  def order_id
    object.order.id
  end
end
