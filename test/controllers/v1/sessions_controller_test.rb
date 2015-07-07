require 'test_helper'

class V1::SessionsControllerTest < ActionController::TestCase
  # test "the truth" do
  #   assert true
  # end


  setup do
    @controller = V1::SessionsController.new
    setWebAPIHeaders
    @user = User.create!( email: 'session@example.com', firstname: 'Testfirst',password:'abc123', lastname: 'TestLast', mobile: '212-555-1212', role: User::ROLES[:customer][:id] )
  end

  test "should create session" do

    @user.token_expiration = Time.now
    @user.save
    #@request.headers["Authorization"] = ActionController::HttpAuthentication::Basic.encode_credentials(@user.email, @user.password)
    token_expiration = @user.token_expiration

    post :create,{email:@user.email, password:@user.password}
    @user.reload
    assert_response :success
    session_data = json(response.body)
    assert_not_nil session_data[:auth_token]
    assert_not_nil session_data[:firstname]
    assert_not_equal token_expiration, @user.token_expiration
    assert_operator DateTime.current.advance(years:0,months:1,weeks: 0, days: 0,hours:0,minutes:-1),:<=, @user.token_expiration.utc.to_datetime
    assert_operator @user.token_expiration.utc.to_datetime,:<=, DateTime.current.advance(years:0,months:1,weeks: 0, days: 0,hours:0,minutes:1)
  end


  test "should fail creating session for archived user" do

    post :create,{email:@user.email, password:@user.password}

    assert_response :success

    @user.archive

    post :create,{email:@user.email, password:@user.password}

    assert_response :unauthorized
  end


  test "should fail creating session for user with archived venue" do

    post :create,{email:@user.email, password:@user.password}

    assert_response :success
    venue = venues(:archivedVenue)
    @user.venue_id = venue.id
    @user.save

    post :create,{email:@user.email, password:@user.password}

    assert_response :unauthorized

  end


  test "should destroy session" do

    setWebAPIHeaders @user.auth_token
    delete :destroy,id:@user
    assert_response :success
    @user.reload
    assert_operator @user.token_expiration.utc,:<=,Time.now.utc
  end



  test "should send password reset token" do
    greg = users(:greg)

    current_deliveries = ActionMailer::Base.deliveries.count

    post :password_reset,{email_or_mobile:greg.email}
    greg.reload
    assert_response :success
    assert_not_nil greg.password_reset_token
    assert_not_nil greg.password_expires_after
    assert_operator DateTime.current.advance(years:0,months:0,weeks: 0, days: 1,hours:0,minutes:-1),:<=, greg.password_expires_after.utc.to_datetime
    assert_operator greg.password_expires_after.utc.to_datetime,:<=, DateTime.current.advance(years:0,months:0,weeks: 0, days: 1,hours:0,minutes:1)
    assert_not_equal current_deliveries, ActionMailer::Base.deliveries.count
  end


  test "should send password reset token to mobile" do
    greg = users(:greg)
    post :password_reset,{email_or_mobile:greg.mobile}
    greg.reload
    assert_response :success
    assert_not_nil greg.password_reset_token
    assert_not_nil greg.password_expires_after
    assert_operator DateTime.current.advance(years:0,months:0,weeks: 0, days: 1,hours:0,minutes:-1),:<=, greg.password_expires_after.utc.to_datetime
    assert_operator greg.password_expires_after.utc.to_datetime,:<=, DateTime.current.advance(years:0,months:0,weeks: 0, days: 1,hours:0,minutes:1)
  end

end
