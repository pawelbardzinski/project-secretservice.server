require 'test_helper'

class UsersIntegrationTest <  ActionDispatch::IntegrationTest

  # Called before every test method runs. Can be used
  # to set up fixture information.
  setup do
   @user = users(:admin)
  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.

  def teardown
    # Do nothing
  end


  test "should create user" do
    assert_difference('User.count') do
      post '/v1/users',
           {user: { email: 'test@example.com', firstname: 'Testfirst',password:'abc123', lastname: 'TestLast', mobile: '212-555-1212', role: User::ROLES[:customer][:id] }}.to_json ,
           createWebAPIHeaderHash
      assert_response :success
    end
    assert_equal Mime::JSON,response.content_type

    user_data = json(response.body)

  end

  test "should create user without usertype" do
    assert_difference('User.count') do
      post '/v1/users',
           {user: { email: 'test@example.com', firstname: 'Testfirst',password:'abc123', lastname: 'TestLast', mobile: '212-555-1212'}}.to_json ,
           createWebAPIHeaderHash(@user.auth_token)
      assert_response :success
    end
    assert_equal Mime::JSON,response.content_type

    user_data = json(response.body)
    assert_equal User::ROLES[:customer][:id],user_data[:role]

  end


  test "should update user JSON" do
    user = User.create!( email: 'test1@example.com', firstname: 'Testfirst',password:'abc123', lastname: 'TestLast', mobile: '212-555-1212', role: User::ROLES[:customer][:id] )
    header = createWebAPIHeaderHash(user.auth_token)
    put "/v1/users/#{user.id}",
        {user: { email: user.email, firstname: user.firstname,password:user.password, lastname: user.lastname, mobile: '212-555-1213', role: user.role }}.to_json ,
        header

    user_data = json(response.body)
    assert_response :success
    assert_equal Mime::JSON,response.content_type

    assert_equal '2125551213',user_data[:mobile]
    assert_equal user_data[:mobile],user.reload.mobile
    assert_nil user_data[:password]
    assert_nil user_data[:password_digest]

  end

  test "should update user JSON only mobile" do
    user =  User.create!( email: 'test1@example.com', firstname: 'Testfirst',password:'abc123', lastname: 'TestLast', mobile: '212-555-1212', role: User::ROLES[:customer][:id] )
    header = createWebAPIHeaderHash(user.auth_token)
    put "/v1/users/#{user.id}",
        {user: { mobile: '212-555-1213' }}.to_json ,
        header

    user_data = json(response.body)
    assert_response :success
    assert_equal Mime::JSON,response.content_type
    user.reload
    assert_equal '2125551213',user_data[:mobile]
    assert_equal user_data[:mobile],user.mobile
    assert_equal user_data[:email],user.email
    assert_equal user_data[:firstname],user.firstname
    assert_equal user_data[:lastname],user.lastname
    assert_equal user_data[:role],user.role
    assert_nil user_data[:password]
    assert_nil user_data[:password_digest]

  end

  test "should get new user JSON" do
      get '/v1/users/new', {},createWebAPIHeaderHash
      assert_response :success
      assert_equal Mime::JSON,response.content_type
  end


end