json.array!(@venues) do |venue|
  json.extract! venue, :id, :name, :latitude, :longitude, :address_line_1, :address_line_2, :city, :state, :zip_code, :country
  json.url venue_url(venue, format: :json)
end
