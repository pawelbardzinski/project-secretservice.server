json.array!(@payment_options) do |payment_option|
  json.extract! payment_option, :id, :last_4, :credit_card_brand, :user_id
  json.url payment_option_url(payment_option, format: :json)
end
