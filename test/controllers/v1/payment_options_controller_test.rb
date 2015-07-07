require 'test_helper'

class V1::PaymentOptionsControllerTest < ActionController::TestCase
  setup do
    @controller = V1::PaymentOptionsController.new
    @payment_option = payment_options(:visa_1234)
    @user = User.find(@payment_option.user_id)
    setWebAPIHeaders @user.auth_token

  end

  test "should create payment option" do
    assert_difference('PaymentOption.count') do
      post :create,user_id:@user.id, payment_option: {user_id:@user.id, credit_card_brand: 'VISA', payment_identifier: '4242424242421234', payment_type:PaymentOption::PAYMENT_TYPES[:credit_card][:id]}
    end
    payment_option_data = json(response.body)
    payment_option_from_db = PaymentOption.find(payment_option_data[:id])
    assert_equal '1234', payment_option_from_db.last_4
  end



  test "should create membership payment option" do
    assert_difference('PaymentOption.count') do
      post :create,user_id:@user.id, payment_option: {user_id:@user.id, payment_identifier: '1234',venue_id:1, payment_type:PaymentOption::PAYMENT_TYPES[:membership_id][:id]}
    end
    payment_option_data = json(response.body)
    payment_option_from_db = PaymentOption.find(payment_option_data[:id])
    assert_equal '1234', payment_option_from_db.last_4
  end



  test "should return validation error for missing credit card number" do

    post :create,user_id:@user.id, payment_option: {user_id:@user.id, credit_card_brand: 'VISA', payment_identifier: '', payment_type:PaymentOption::PAYMENT_TYPES[:credit_card][:id]}
    assert_response :unprocessable_entity
    payment_option_data = json(response.body)

    assert_equal "Credit card or Membership Id can't be blank", payment_option_data[0]
  end


  test "should update" do
    put :update, user_id: @payment_option.user_id, id:@payment_option, payment_option: {user_id:@payment_option.user_id, credit_card_brand:@payment_option.credit_card_brand, payment_identifier: '4242424242424321', payment_type:PaymentOption::PAYMENT_TYPES[:credit_card][:id]}
    assert_response :success
    payment_option_data = json(response.body)
    payment_option_from_db = PaymentOption.find(payment_option_data[:id])
    assert_equal '4321',payment_option_from_db.last_4
  end



  test "should not be able to update another users payment options" do
    user = users(:two)
    setWebAPIHeaders user.auth_token
    put :update, user_id: @payment_option.user_id, id:@payment_option, payment_option: {user_id:@payment_option.user_id, credit_card_brand:@payment_option.credit_card_brand, payment_identifier: '4242424242424321', payment_type:PaymentOption::PAYMENT_TYPES[:credit_card][:id]}
    assert_response :unauthorized
  end


  test "should get payment options" do
    get :show,user_id:@payment_option.user_id, id: @payment_option
    assert_response :success
  end

  test "should get all user payment options" do
    get :index,user_id:@payment_option.user_id
    assert_response :success
  end


  test "should delete" do
    delete :destroy,user_id:@payment_option.user_id, id: @payment_option
    assert_response :success
  end


end
