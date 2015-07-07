require 'test_helper'

class V1::OrdersControllerTest < ActionController::TestCase
  setup do
    @controller = V1::OrdersController.new
    @user = users(:one)
    setWebAPIHeaders @user.auth_token
    @product= products(:bud_light)
    @order = orders(:one)
    @payment_option = payment_options(:visa_1111_for_order_tests)
  end


  test "should get new order" do
    get :new,venue_id: @product.venue_id
    order_data = json(response.body)
    assert_response :success
  end

  test "should create order" do
    assert_difference('Order.count') do
      post :create, venue_id: @product.venue_id,order: {location:'My Location',user_id:@user.id,venue_id:@product.venue_id,payment_option_id:@payment_option.id, order_items_attributes:[{product_id:@product.id,quantity:1}] }
    end
    order_data = json(response.body)
    orderFromDb = Order.find(order_data[:id])
    assert_response :success
    assert_not_nil orderFromDb
    assert_equal Order::STATUSES[:submitted][:id],order_data[:order_status]

    assert_equal @product.id,order_data[:order_items][0][:product_id]
    assert_equal @product.price,order_data[:order_items][0][:price]
    assert_equal 'My Location',order_data[:location]

    assert_payment_option @payment_option,order_data


  end


  test "should create order with order status" do
    assert_difference('Order.count') do
      post :create, venue_id: @product.venue_id,order: {payment_option_id:@payment_option.id, location:'My location',user_id:@user.id,venue_id:@product.venue_id, order_status:99, order_items_attributes:[{product_id:@product.id,price:99.9,quantity:1}] }

      assert_response :success
    end
    order_data = json(response.body)
    orderFromDb = Order.find(order_data[:id])
    assert_not_nil orderFromDb
    assert_equal Order::STATUSES[:submitted][:id],order_data[:order_status]
    assert_equal @product.price,order_data[:order_items][0][:price]
    assert_equal 'My location',order_data[:location]
  end


  test "should create order with " do
    assert_difference('Order.count') do
      post :create, venue_id: @product.venue_id,order: {payment_option_id:@payment_option.id, location:'My location',user_id:@user.id,venue_id:@product.venue_id, order_status:99, order_items_attributes:[{product_id:@product.id,price:99.9,quantity:1}] }

      assert_response :success
    end
    order_data = json(response.body)
    orderFromDb = Order.find(order_data[:id])
    assert_not_nil orderFromDb
    assert_equal Order::STATUSES[:submitted][:id],order_data[:order_status]
    assert_equal @product.price,order_data[:order_items][0][:price]
    assert_equal 'My location',order_data[:location]
    assert_equal @user.firstname + " " + @user.lastname, order_data[:full_name]
    assert_equal @product.name, order_data[:order_items][0][:product_name]
  end


  test "should create order with nil payment option " do
    assert_difference('Order.count') do
      post :create, venue_id: @product.venue_id,order: {payment_option_id:0, location:'My location',user_id:@user.id,venue_id:@product.venue_id, order_status:99, order_items_attributes:[{product_id:@product.id,price:99.9,quantity:1}] }

      assert_response :success
    end
    order_data = json(response.body)
    orderFromDb = Order.find(order_data[:id])
    assert_nil  order_data[:last_4]
    assert_nil  orderFromDb.last_4
  end

  test "should update" do

    payment_option = payment_options(:visa_4242)
    put :update, venue_id: @product.venue_id,id: @order,order: { payment_option_id:payment_option.id }
    assert_response :success
    order_data = json(response.body)
    assert_payment_option payment_option,order_data
  end

  test "should update status" do

    payment_option = payment_options(:visa_4242)
    put :update, venue_id: @product.venue_id,id: @order,order: { order_status:3,payment_option_id:payment_option.id }
    assert_response :success
    order_data = json(response.body)
    assert_equal 3,order_data[:order_status]
  end



  test "should update venue_user_id" do
    waiter = users(:waiter)
    payment_option = payment_options(:visa_4242)
    put :update, venue_id: @product.venue_id,id: @order,order: { order_status:3,venue_user_id:waiter.id,payment_option_id:payment_option.id }
    assert_response :success
    order_data = json(response.body)
    assert_equal 3,order_data[:order_status]
    assert_equal waiter.id,order_data[:venue_user_id]
  end



  test "should update payment_option_id to nil" do
    waiter = users(:waiter)
    put :update, venue_id: @product.venue_id,id: @order,order: { order_status:Order::STATUSES[:submitted][:id],venue_user_id:waiter.id,payment_option_id:0 }
    assert_response :success
    order_data = json(response.body)
    orderFromDb = Order.find(order_data[:id])
    assert_nil  order_data[:last_4]
    assert_nil  orderFromDb.last_4
  end


  test "should not update venue_id, and price " do
    put :update, venue_id: @product.venue_id,id: @order,order: { payment_option_id:@payment_option.id, venue_id: 88, user_id:@user.id, order_items_attributes:[{product_id:@product.id,price:99.9,quantity:1}] }
    assert_response :success
    order_data = json(response.body)
    assert_payment_option @payment_option,order_data
    assert_equal @order.order_status,order_data[:order_status] #should not have changed
    assert_equal @order.user_id,order_data[:user_id] #should not have changed
    assert_equal @order.venue_id,order_data[:venue_id] #should not have changed
    assert_equal @product.price,order_data[:order_items][0][:price]
  end

  test "should not be able to update another users payment options" do
    user = users(:two)
    setWebAPIHeaders user.auth_token
    put :update, venue_id: @product.venue_id,id: @order,order: { payment_option_id:@payment_option.id, order_status:99, venue_id: 88, user_id:@user.id, order_items_attributes:[{product_id:@product.id,price:99.9,quantity:1}] }
    assert_response :unauthorized
  end


  test "a waiter should be able to update another users order" do
    user = users(:waiter)
    setWebAPIHeaders user.auth_token
    put :update, venue_id: @product.venue_id,id: @order,order: { payment_option_id:@payment_option.id, venue_id: 88, user_id:@user.id, order_items_attributes:[{product_id:@product.id,price:99.9,quantity:1}] }
    assert_response :success

  end



  test "should get order" do
    get :show, venue_id: @product.venue_id,id: @order
    assert_response :success
    data = json(response.body)
    assert_not_nil data[:order_items]
    assert_operator  data[:order_items].count, :>, 0
    assert_equal @order.user.firstname + " " + @order.user.lastname, data[:full_name]
    assert_equal @order.order_items[0].product.name, data[:order_items][0][:product_name]
  end

  test "should get all users orders" do
    get :index,venue_id: @product.venue_id
    assert_response :success
    data = json(response.body)
    data.each do |order|
      assert_equal @user.id, order[:user_id]
    end
  end



  test "should get wait staff orders" do
    waiter = users(:waiter)
    get :index,venue_id: @product.venue_id,venue_user_id:waiter.id
    assert_response :success
    data = json(response.body)
    data.each do |order|
      assert_equal waiter.id, user[:venue_user_id]
    end

  end

  test "should mark as archived" do
    delete :destroy,venue_id: @product.venue_id, id: @order
    assert_response :success
    deleted_order = Order.find_by(id:@order.id)
    assert_not_nil deleted_order
    assert_equal Order::STATUSES[:cancelled][:id], deleted_order.order_status
  end



  test "should mark as archived with reason" do
    reason = "this is my reason"
    delete :destroy,venue_id: @product.venue_id, id: @order,cancel_reason:reason
    assert_response :success
    deleted_order = Order.find(@order.id)
    assert_not_nil deleted_order
    assert_equal Order::STATUSES[:cancelled][:id], deleted_order.order_status
    assert_equal reason, deleted_order.cancel_reason
  end


  test "should not delete completed orders" do
    @order.order_status = Order::STATUSES[:completed][:id]
    @order.save
    delete :destroy,venue_id: @product.venue_id, id: @order
    assert_response :unprocessable_entity
    @order.reload
    assert_equal Order::STATUSES[:completed][:id], @order.order_status
  end


  def assert_payment_option(payment_option,order)
    assert_equal payment_option.last_4,order[:last_4]
    assert_equal payment_option.credit_card_brand,order[:credit_card_brand]
  end


end
