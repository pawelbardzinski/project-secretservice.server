json.array!(@orders) do |order|
  json.extract! order, :id, :user_id, :venue_id, :order_status, :last_4, :credit_card_brand, :section,:row,:seat
  json.url order_url(order, format: :json)
end
