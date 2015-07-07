require 'test_helper'

class ProductsIntegrationTest <  ActionDispatch::IntegrationTest

  # Called before every test method runs. Can be used
  # to set up fixture information.
  setup do
    @user = users(:one)
    @headers = createWebAPIHeaderHash(@user.auth_token)
    @product = products(:bud_light)
  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.

  def teardown
    # Do nothing
  end

  test "should get products" do
    get "/v1/venues/#{@product.venue_id}/products", {},@headers
    assert_response :success
    assert_equal Mime::JSON,response.content_type
  end


  test "should get product by id" do
    get "/v1/venues/#{@product.venue_id}/products/#{@product.id}", {},@headers
    product_data= json(response.body)
    assert_response :success
    assert_equal Mime::JSON,response.content_type
    assert_equal product_data[:name],@product.name
  end

end