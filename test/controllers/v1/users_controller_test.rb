require 'active_support/all'
require 'test_helper'

class V1::UsersControllerTest < ActionController::TestCase
  setup do
    @controller = V1::UsersController.new
    @user = users(:one)
    @waiter = users(:waiter)
    @admin = users(:admin)
    @venue_admin = users(:venue_admin)
    setWebAPIHeaders @user.auth_token
  end

  test "should create user" do
    @request.headers["Authorization"] = ''
    assert_difference('User.count') do
      post :create, user: { email:  'test999@example.com', firstname: @user.firstname, lastname: @user.lastname, password:'abc123',mobile: @user.mobile }
    end
    user_data = json(response.body)
    userFromDb = User.find(user_data[:id])
    assert_not_nil userFromDb.auth_token
    assert_not_nil userFromDb.token_expiration

    assert_equal 1, userFromDb.role
  end



  test "should create user as customer" do
    @request.headers["Authorization"] = ''
    assert_difference('User.count') do
      post :create, user: { email:  'test999@example.com', firstname: @user.firstname, lastname: @user.lastname, password:'abc123',mobile: @user.mobile,role:2 }
    end
    user_data = json(response.body)
    userFromDb = User.find(user_data[:id])
    assert_not_nil userFromDb.auth_token
    assert_not_nil userFromDb.token_expiration

    assert_equal 1, userFromDb.role
  end



  test "should return validation error for missing email" do
    @request.headers["Authorization"] = ''
    post :create, user: { firstname: @user.firstname, lastname: @user.lastname, password:'abc123',mobile: @user.mobile, role: @user.role }

    assert_response :unprocessable_entity
    user_data = json(response.body)
    assert_equal "Email can't be blank", user_data[0]
  end

  test "should update" do
    patch :update, id: @user, user: { email: @user.email, firstname: @user.firstname, lastname: @user.lastname, mobile: '212-555-9999', role: @user.role }
    assert_response :success
    user_data = json(response.body)
    assert_equal '2125559999',user_data[:mobile]
    assert_equal user_data[:mobile],@user.reload.mobile
  end


  test "should get user" do
    get :show, id: @user
    assert_response :success
  end



  test "venue admin should get all venue users" do
    setWebAPIHeaders @venue_admin.auth_token
    get :index,{}
    assert_response :success
    data = json(response.body)
    data.each do |user|
      assert_equal @venue_admin.venue_id, user[:venue_id]
    end
  end



  test "admin should get all users" do
    setWebAPIHeaders @admin.auth_token
    get :index,{}
    assert_response :success
  end

  test "customers should not get all users" do
    get :index,{}
    assert_response :unauthorized
  end


  test "should delete" do
    delete :destroy, id: @user
    assert_response :success
    deleted_user = User.find_by(id:@user.id)
    assert_equal true, deleted_user.archived
  end


  test "should have bad credentials" do
    @request.headers["x-auth-token"] = ''
    patch :update, id: @user, user: { email:  @user.email, firstname: @user.firstname, lastname: @user.lastname, mobile: @user.mobile, role: @user.role }
    assert_response :unauthorized
    data = json(response.body)
    assert_equal "Bad credentials", data[:message]
  end


  test "should have bad credentials with expired token" do
    user = users(:tokenexpired)
    @request.headers["x-auth-token"] = token_header(user.auth_token)
    patch :update, id: user, user: { email: user.email, firstname: user.firstname, lastname: user.lastname,password:'abc123', mobile: user.mobile, role: user.role }
    assert_response :unauthorized
  end

  test "should find by token" do
    user = users(:greg)
    user.password_reset_token = "reset"
    user.password_expires_after =   DateTime.current.advance(years:0,months:0,weeks: 0, days: 0,hours:0,minutes:1)
    assert_equal true, user.save
    user.reload
    get :get_by_token, token: "reset"
    assert_response :ok
    data = json(response.body)
    assert_equal user.id, data[:id]


  end



  test "should find not by token" do
    user = users(:greg)
    user.password_reset_token = "reset"
    user.password_expires_after =   DateTime.current.advance(years:0,months:0,weeks: 0, days: 0,hours:0,minutes:1)
    assert_equal true, user.save
    user.reload
    get :get_by_token, token: "resetbad"
    assert_response :not_found
  end


  test "should find not by token with expired token" do
    user = users(:greg)
    user.password_reset_token = "reset"
    user.password_expires_after =   DateTime.current.advance(years:0,months:0,weeks: 0, days: 0,hours:0,minutes:-1)
    assert_equal true, user.save
    user.reload
    get :get_by_token, token: "resetbad"
    assert_response :not_found
  end


  test "customer should not update another user" do
    user = users(:two)
    patch :update, id: user, user: { email: user.email, firstname: user.firstname, lastname: user.lastname, mobile: '212-555-9999', role: user.role }
    assert_response :unauthorized
  end


  test "waiter should not update another user" do
    setWebAPIHeaders @waiter.auth_token
    user = users(:two)
    patch :update, id: user, user: { email: user.email, firstname: user.firstname, lastname: user.lastname, mobile: '212-555-9999', role: user.role }
    assert_response :unauthorized
  end


  test "venue admin should not update another venue user" do
    setWebAPIHeaders @venue_admin.auth_token
    user = users(:stlo_waiter)
    patch :update, id: user, user: { email: user.email, firstname: user.firstname, lastname: user.lastname, mobile: '212-555-9999', role: user.role }
    assert_response :unauthorized
  end

  test "venue admin should update venue user" do
    setWebAPIHeaders @venue_admin.auth_token
    patch :update, id: @waiter, user: { email: @waiter.email, firstname: @waiter.firstname, lastname: @waiter.lastname, mobile: '212-555-9999', role: @waiter.role }
    assert_response :success
  end

  test "admin should update venue user" do
    setWebAPIHeaders @admin.auth_token
    patch :update, id: @venue_admin, user: { email: @venue_admin.email, firstname: @venue_admin.firstname, lastname: @venue_admin.lastname, mobile: '212-555-9999', role: @venue_admin.role }
    assert_response :success
  end
end
