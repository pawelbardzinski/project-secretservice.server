json.array!(@users) do |user|
  json.extract! user, :id, :firstname, :lastname, :email, :mobile, :usertype
  json.url user_url(user, format: :json)
end
