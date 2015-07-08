class OrderItemsSerializer < ActiveModel::Serializer
  attributes :id, :quantity, :price, :created_at, :venue

  def venue
    venue_id = object.order.venue_id
    venue_id && venue_id > 0 ? Venue.find(venue_id).name : ""
  end
end
