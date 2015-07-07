json.array!(@products) do |product|
  json.extract! product, :id, :name, :price, :rating, :venue_id
  json.url product_url(product, format: :json)
end
