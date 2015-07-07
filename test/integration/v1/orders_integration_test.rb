require 'test_helper'

class OrdersIntegrationTest <  ActionDispatch::IntegrationTest

  # Called before every test method runs. Can be used
  # to set up fixture information.
  setup do

    @customer = users(:one)
    @user = users(:waiter)
    @headers = createWebAPIHeaderHash(@user.auth_token)
    @product = products(:bud_light)
    @order = orders(:one)
  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.

  def teardown
    # Do nothing
  end

  test "should get orders for waiter" do
    get "/v1/venues/#{@user.venue_id}/orders", {},@headers
    assert_response :success
    assert_equal Mime::JSON,response.content_type

  end


  test "should get orders assigned to waiter" do
    get "/v1/venues/#{@user.venue_id}/orders?venue_user_id=#{@user.id}", {},@headers
    assert_response :success
    assert_equal Mime::JSON,response.content_type

  end

  test "should get 401 for waiter from wrong venue" do
    get "/v1/venues/99/orders", {},@headers
    assert_response :unauthorized
    assert_equal Mime::JSON,response.content_type

  end


  test "should get order" do
    get "/v1/venues/#{@order.venue_id}/orders/#{@order.id}", {},@headers
    assert_response :success
    data = json(response.body)
    assert_not_nil data[:order_items]
    assert_operator data[:order_items].count, :>, 0
  end

  test "should create order" do
    assert_difference('Order.count') do
      post "/v1/venues/#{@product.venue_id}/orders",
           {order:{location:'My Location',user_id:@customer.id,venue_id:@product.venue_id, order_items_attributes:[{product_id:@product.id,quantity:1}] }}.to_json,
           createWebAPIHeaderHash(@customer.auth_token)
    end
    order_data = json(response.body)
    orderFromDb = Order.find(order_data[:id])
    orderItemsFromDb = OrderItem.find_by_order_id(order_data[:id])
    assert_response :success
    assert_not_nil orderFromDb
    assert_equal Order::STATUSES[:submitted][:id],order_data[:order_status]

    assert_equal @product.id,order_data[:order_items][0][:product_id]
    assert_equal @product.price,order_data[:order_items][0][:price]
    assert_equal 'My Location',order_data[:location]



  end




  test "should mark as archived with reason" do
    reason = "this is my reason"
    delete  "/v1/venues/#{@product.venue_id}/orders/#{@order.id}?cancel_reason=#{URI.escape(reason)}",{} ,createWebAPIHeaderHash(@customer.auth_token)
    assert_response :success
    deleted_order = Order.find(@order.id)
    assert_not_nil deleted_order
    assert_equal Order::STATUSES[:cancelled][:id], deleted_order.order_status
    assert_equal reason, deleted_order.cancel_reason
  end
end