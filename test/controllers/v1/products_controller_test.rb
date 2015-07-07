require 'test_helper'

class V1::ProductsControllerTest < ActionController::TestCase

  setup do
    @controller = V1::ProductsController.new
    @user = users(:one)
    @venue_admin = users(:venue_admin)
    @wait_staff = users(:waiter)
    @admin = users(:admin)
    setWebAPIHeaders @user.auth_token
    @product = products(:bud_light)
    @lat = 38.633768
    @long = -90.205653
  end

  test "should get index" do
    get :index,venue_id: @product.venue_id
    assert_response :success
    product_data = json(response.body)
    assert_equal 3 , product_data.count
  end


  test "should show" do
    get :show,{ id: @product,venue_id: @product.venue_id}
    assert_response :success
    product_data = json(response.body)
    assert_equal @product.name, product_data[:name]
  end

  test "should create product" do
    setWebAPIHeaders @venue_admin.auth_token
    @product.name = 'new product'
    assert_difference('Product.count') do
      post :create,venue_id:@product.venue_id, product: { name: @product.name, price: @product.price, rating: @product.rating, venue_id: @product.venue_id }
    end

    assert_response :success
    product_data = json(response.body)
    assert_equal @product.name, product_data[:name]
  end

  test "should update product" do
    setWebAPIHeaders @venue_admin.auth_token
    @product.name = 'updated product'
    put :update, id: @product,venue_id: @product.venue_id, product: { name: @product.name, price: @product.price, rating: @product.rating, venue_id: @product.venue_id }

    assert_response :success
    product_data = json(response.body)
    assert_equal @product.name, product_data[:name]
  end


  test "venue admin should not update another venues product" do
    setWebAPIHeaders @venue_admin.auth_token
    product = products(:slso_budweiser)
    product.name = 'updated product'
    put :update, id: product,venue_id: product.venue_id, product: { name: product.name, price: product.price, rating: product.rating, venue_id: product.venue_id }
    assert_response :unauthorized
  end

  test "should destroy product" do
    setWebAPIHeaders @venue_admin.auth_token
    assert_difference('Product.count', 0) do
      delete :destroy,venue_id: @product.venue_id, id: @product
    end

    assert_response :no_content
  end


  test "customer should not create product" do
    @product.name = 'new product'
    post :create,venue_id:@product.venue_id, product: { name: @product.name, price: @product.price, rating: @product.rating, venue_id: @product.venue_id }
    assert_response :unauthorized
  end


  test "customer should not update product" do
    @product.name = 'updated product'
    put :update, id: @product,venue_id: @product.venue_id, product: { name: @product.name, price: @product.price, rating: @product.rating, venue_id: @product.venue_id }
    assert_response :unauthorized
  end

  test "customer should not destroy product" do
    delete :destroy,venue_id: @product.venue_id, id: @product
    assert_response :unauthorized
  end

  test "wait staff should not create product" do
    setWebAPIHeaders @wait_staff.auth_token
    @product.name = 'new product'
    post :create,venue_id:@product.venue_id, product: { name: @product.name, price: @product.price, rating: @product.rating, venue_id: @product.venue_id }
    assert_response :unauthorized
  end


  test "wait staff should not update product" do
    setWebAPIHeaders @wait_staff.auth_token
    @product.name = 'updated product'
    put :update, id: @product,venue_id: @product.venue_id, product: { name: @product.name, price: @product.price, rating: @product.rating, venue_id: @product.venue_id }
    assert_response :unauthorized
  end

  test "wait staff should not destroy product" do
    setWebAPIHeaders @wait_staff.auth_token
    delete :destroy,venue_id: @product.venue_id, id: @product
    assert_response :unauthorized
  end

  test "admin should not create product" do
    setWebAPIHeaders @admin.auth_token
    @product.name = 'new product'
    post :create,venue_id:@product.venue_id, product: { name: @product.name, price: @product.price, rating: @product.rating, venue_id: @product.venue_id }
    assert_response :unauthorized
  end


  test "admin should not update product" do
    setWebAPIHeaders @admin.auth_token
    @product.name = 'updated product'
    put :update, id: @product,venue_id: @product.venue_id, product: { name: @product.name, price: @product.price, rating: @product.rating, venue_id: @product.venue_id }
    assert_response :unauthorized
  end

  test "admin should not destroy product" do
    setWebAPIHeaders @admin.auth_token
    delete :destroy,venue_id: @product.venue_id, id: @product
    assert_response :unauthorized
  end


end
