require 'test_helper'

class V1::VenuesControllerTest < ActionController::TestCase

  setup do
    Geocoder.configure(:lookup => :test)
    stub_geo_code_addresses
    @controller = V1::VenuesController.new
    @user = users(:one)
    @venue_admin = users(:venue_admin)
    @wait_staff = users(:waiter)
    @admin = users(:admin)
    setWebAPIHeaders @user.auth_token
    @venue = venues(:kirkwood_station_brewing_company)
    @lat = 38.633768
    @long = -90.205653
  end

  test "should get index" do
    venue = venues(:arts_theatre_in_excellence)
    get :index
    assert_response :success
    venue_data = json(response.body)
    assert_operator 6 ,:==, venue_data.count
  end



  test "should get by lat and long" do
    venue = venues(:st_louis_symphony_orchestra)
    get :index,{latitude:@lat ,longitude:@long}
    assert_response :success
    venue_data = json(response.body)
    assert_operator 4, :==,venue_data.count
  end


  test "should get by lat and long order by distance" do
    venue = venues(:windows_on_washington)
    get :index,{latitude:@lat ,longitude:@long,order:'distance'}
    assert_response :success
    venue_data = json(response.body)
    assert_operator 4, :==,venue_data.count
    assert_equal venue.name,venue_data[0][:name]
  end


  test "should get by lat, long and search term name match" do
    venue = venues(:the_firebird)
    get :index,{latitude:@lat ,longitude:@long, search_term:'the'}
    assert_response :success
    venue_data = json(response.body)
    assert_operator 2, :==,venue_data.count
  end


  test "should get by lat, long and search term city match" do
    venue = venues(:the_firebird)
    get :index,{latitude:@lat ,longitude:@long, search_term:'st louis'}
    assert_response :success
    venue_data = json(response.body)
    assert_operator 4, :==,venue_data.count
  end



  test "should search term match all" do
    venue = venues(:the_firebird)
    get :index, search_term:'i'
    assert_response :success
    venue_data = json(response.body)
    assert_operator 6, :==,venue_data.count
  end

  test "should not find get by lat, long and name 'Kirkwood'" do
    get :index,{latitude:@lat ,longitude:@long, search_term:'Kirkwood'}
    assert_response :success
    venue_data = json(response.body)
    assert_operator 0, :==,venue_data.count
  end


  test "should find get by name 'Kirkwood'" do
    get :index,{search_term:'Kirkwood'}
    assert_response :success
    venue_data = json(response.body)
    assert_operator 1, :==,venue_data.count
  end

  test "should not find get by name 'aaa'" do
    get :index,{search_term:'aaa'}
    assert_response :success
    venue_data = json(response.body)
    assert_operator 0, :==,venue_data.count
  end


  test "should get by lat and long with distance 15 miles" do
    get :index,{latitude:@lat ,longitude:@long, distance:15}
    assert_response :success
    venue_data = json(response.body)
    assert_operator 6, :==,venue_data.count
  end

  test "should get by id" do
    get :show, id: @venue
    assert_response :success
    venue_data = json(response.body)
    assert_equal @venue.name, venue_data[:name]
  end

  test "should mark as archived" do
    setWebAPIHeaders @venue_admin.auth_token
    delete :destroy, id: @venue
    assert_response :success
    @venue.reload
    assert_equal true, @venue.archived
  end

  test "should get new" do
    setWebAPIHeaders @admin.auth_token
    get :new
    assert_response :success
  end

  test "admin should create venue" do
    setWebAPIHeaders @admin.auth_token
    assert_difference('Venue.count') do
      post :create, venue: { address_line_1: @venue.address_line_1, address_line_2: @venue.address_line_2, city: @venue.city, country: @venue.country, latitude: @venue.latitude, longitude: @venue.longitude, name: @venue.name, state: @venue.state, zip_code: @venue.zip_code }
    end
    assert_response :success
    venue_data = json(response.body)
    assert_equal @venue.name, venue_data[:name]
  end

  test "admin should update venue" do
    setWebAPIHeaders @admin.auth_token
    @venue.name = "new name"
    put :update, id: @venue, venue: { address_line_1: @venue.address_line_1, address_line_2: @venue.address_line_2, city: @venue.city, country: @venue.country, latitude: @venue.latitude, longitude: @venue.longitude, name: @venue.name, state: @venue.state, zip_code: @venue.zip_code }

    assert_response :success
    venue_data = json(response.body)
    assert_equal @venue.name, venue_data[:name]
  end

  test "customer should not create venue" do
    post :create, venue: { address_line_1: @venue.address_line_1, address_line_2: @venue.address_line_2, city: @venue.city, country: @venue.country, latitude: @venue.latitude, longitude: @venue.longitude, name: @venue.name, state: @venue.state, zip_code: @venue.zip_code }
    assert_response :unauthorized
  end

  test "customer should not update venue" do
    @venue.name = "new name"
    put :update, id: @venue, venue: { address_line_1: @venue.address_line_1, address_line_2: @venue.address_line_2, city: @venue.city, country: @venue.country, latitude: @venue.latitude, longitude: @venue.longitude, name: @venue.name, state: @venue.state, zip_code: @venue.zip_code }

    assert_response :unauthorized
  end


  test "wait staff should not create venue" do
    setWebAPIHeaders @wait_staff.auth_token
    post :create, venue: { address_line_1: @venue.address_line_1, address_line_2: @venue.address_line_2, city: @venue.city, country: @venue.country, latitude: @venue.latitude, longitude: @venue.longitude, name: @venue.name, state: @venue.state, zip_code: @venue.zip_code }
    assert_response :unauthorized
  end

  test "wait staff should not update venue" do
    setWebAPIHeaders @wait_staff.auth_token
    @venue.name = "new name"
    put :update, id: @venue, venue: { address_line_1: @venue.address_line_1, address_line_2: @venue.address_line_2, city: @venue.city, country: @venue.country, latitude: @venue.latitude, longitude: @venue.longitude, name: @venue.name, state: @venue.state, zip_code: @venue.zip_code }

    assert_response :unauthorized
  end


  test "venue admin should not create venue" do
    setWebAPIHeaders @venue_admin.auth_token
    post :create, venue: { address_line_1: @venue.address_line_1, address_line_2: @venue.address_line_2, city: @venue.city, country: @venue.country, latitude: @venue.latitude, longitude: @venue.longitude, name: @venue.name, state: @venue.state, zip_code: @venue.zip_code }
    assert_response :unauthorized
  end

  test "venue admin should not update another venue" do
    setWebAPIHeaders @wait_staff.auth_token
    venue = venues(:st_louis_symphony_orchestra)
    venue.name = "new name"
    put :update, id: venue, venue: { address_line_1: venue.address_line_1, address_line_2:venue.address_line_2, city: venue.city, country: venue.country, latitude: venue.latitude, longitude: venue.longitude, name: venue.name, state: venue.state, zip_code: venue.zip_code }

    assert_response :unauthorized
  end



  test "should update venue" do
    setWebAPIHeaders @venue_admin.auth_token
    @venue.name = "new name"
    put :update, id: @venue, venue: { address_line_1: @venue.address_line_1, address_line_2: @venue.address_line_2, city: @venue.city, country: @venue.country, latitude: @venue.latitude, longitude: @venue.longitude, name: @venue.name, state: @venue.state, zip_code: @venue.zip_code }

    assert_response :success
    venue_data = json(response.body)
    assert_equal @venue.name, venue_data[:name]
  end

  def stub_geo_code_addresses

    Geocoder::Lookup::Test.add_stub(
        "105 E Jefferson Ave, 63122, Saint Louis, MO, US", [
        {
            latitude: 38.55555,
            longitude: -90.55555,
            address: "105 E Jefferson Ave, 63122, Saint Louis, MO, US",
            state: "Missouri",
            state_code: "MO",
            zip_code: "63103",
            country:  "United States",
            country_code:  "US"
        }
    ])

  end
end
