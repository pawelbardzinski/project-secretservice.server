require 'test_helper'

class VenueTest < ActiveSupport::TestCase
  setup do
    Geocoder.configure(:lookup => :test)
    stub_geo_code_addresses

    @venue = Venue.new({name:"The Firebird", address_line_1:"2706 Olive St", city:"Saint Louis", state:"MO", zip_code:"63103",country:"US"})
    @venue.save

    @lat = @venue.latitude
    @long = @venue.longitude
  end

  test "saving sets lat and long" do
    assert_not_nil @venue.latitude
    assert_not_nil @venue.longitude
  end

  test "update address line 1 changes lat and long" do
    @venue.update(address_line_1:"1706 Olive St")
    assert_lat_long_changed @lat,@long, @venue.latitude, @venue.longitude
  end

  test "update address line 2 changes lat and long" do
    set_lat_long_to_bad_values
    #should not change lat and long
    @venue.update(address_line_2:"suite 200")
    assert_lat_long_did_not_change @lat,@long, @venue.latitude, @venue.longitude
  end

  test "update city changes lat and long" do
    @venue.update(city:"clayton")
    set_lat_long_to_bad_values
    @venue.update(city:"Saint Louis")
    assert_lat_long_did_not_change @lat,@long, @venue.latitude, @venue.longitude
  end


  test "update state changes lat and long" do
    @venue.update(state:"IL")
    set_lat_long_to_bad_values
    @venue.update(state:"MO")
    assert_lat_long_did_not_change @lat,@long, @venue.latitude, @venue.longitude
  end

  test "update zip code changes lat and long" do
    @venue.update(zip_code:"61265")
    set_lat_long_to_bad_values
    @venue.update(zip_code:"63103")
    assert_lat_long_did_not_change @lat,@long, @venue.latitude, @venue.longitude
  end

  test "update country changes lat and long" do
    @venue.update(country:"CA")
    assert_lat_long_did_not_change 38.66666,-90.66666, @venue.latitude, @venue.longitude
    @venue.update(country:"US")
    #Verfiy it was updated back to original
    assert_lat_long_did_not_change @lat,@long, @venue.latitude, @venue.longitude
  end

  test "update name does not change lat and long" do
    lat = 99
    long = 88
    #chnage lat and long to verify updating the name does not recalc lat or long.
    @venue.update(latitude:lat,longitude:long)

    @venue.update(name:"test")
    assert_lat_long_did_not_change lat,long, @venue.latitude, @venue.longitude
  end


  test "validate name required" do
    validates_required Venue.new(), :name
  end

  test "validate address line one required" do
    validates_required Venue.new(), :address_line_1
  end

  test "validate city required" do
    validates_required Venue.new(), :city
  end

  test "validate state required" do
    validates_required Venue.new(), :state
  end

  test "validate zip code required" do
    validates_required Venue.new(), :zip_code
  end

  def set_lat_long_to_bad_values
    #should not change the lat and long so we will set it to bad values
    @venue.update(latitude:99,longitude:88)
    assert_lat_long_changed @lat,@long, @venue.latitude, @venue.longitude
  end

  def assert_lat_long_did_not_change(lat,long,newlat,newlong)
    assert_equal lat, newlat
    assert_equal long, newlong
  end

  def assert_lat_long_changed(lat,long,newlat,newlong)
    assert_not_equal lat, newlat
    assert_not_equal long, newlong
  end

  test "destroy should just mark as archived" do
    venue = Venue.new({name:"The Old Firebird", address_line_1:"2706 Olive St", city:"Saint Louis", state:"MO", zip_code:"63103",country:"US"})
    venue.save
    venue.reload
    venue.archive
    assert_equal true, venue.archived
    assert_not_nil Venue.find(venue.id)
  end

  def stub_geo_code_addresses

    Geocoder::Lookup::Test.add_stub(
        "2706 Olive St, 63103, Saint Louis, MO, US", [
        {
            latitude: 38.633869,
            longitude: -90.216621,
            address: "2706 Olive St, 63103, Saint Louis, MO, US",
            state: "Missouri",
            state_code: "MO",
            zip_code: "63103",
            country:  "United States",
            country_code:  "US"
        }
    ])

    Geocoder::Lookup::Test.add_stub(
        "2706 Olive St, 63103, clayton, MO, US", [
        {
            latitude: 38.77777,
            longitude: -90.77777,
            address: "2706 Olive St, 63103, clayton, MO, US",
            state: "Missouri",
            state_code: "MO",
            zip_code: "63103",
            country:  "United States",
            country_code:  "US"
        }
    ])



    Geocoder::Lookup::Test.add_stub(
        "2706 Olive St, 63103, Saint Louis, MO, CA", [
        {
            latitude: 38.66666,
            longitude: -90.66666,
            address: "2706 Olive St, 63103, Saint Louis, MO, CA",
            state: "Missouri",
            state_code: "MO",
            zip_code: "63103",
            country:  "Canada",
            country_code:  "CA"
        }
    ])

    Geocoder::Lookup::Test.add_stub(
        "1706 Olive St, 63103, Saint Louis, MO, US", [
        {
            latitude: 38.99999,
            longitude: -90.99999,
            address: "1706 Olive St, 63103, Saint Louis, MO, US",
            state: "Missouri",
            state_code: "MO",
            zip_code: "63103",
            country:  "United States",
            country_code:  "US"
        }
    ])



    Geocoder::Lookup::Test.add_stub(
        "2706 Olive St, 61265, Saint Louis, MO, US", [
        {
            latitude: 38.44444,
            longitude: -90.44444,
            address: "2706 Olive St, 61265, Saint Louis, MO, US",
            state: "Missouri",
            state_code: "MO",
            zip_code: "63103",
            country:  "United States",
            country_code:  "US"
        }
    ])

    Geocoder::Lookup::Test.add_stub(
        "2706 Olive St, 63103, Saint Louis, IL, US", [
        {
            latitude: 38.55555,
            longitude: -90.55555,
            address: "2706 Olive St, 63103, Saint Louis, IL, US",
            state: "Illinois",
            state_code: "IL",
            zip_code: "63103",
            country:  "United States",
            country_code:  "US"
        }
    ])


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
