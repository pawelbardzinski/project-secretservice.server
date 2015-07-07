require 'test_helper'

class APIVersionTest < ActiveSupport::TestCase

  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    # Do nothing

  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.

  def teardown
    # Do nothing
  end

  test "matches default" do
    request= APIVersionTest::Request.new
    request.headers = {}
    request.headers['test']='test'
    apiVersion = ApiVersion.new("vx",true)
    assert apiVersion.matches?(request)
  end


  test "does not match" do
    request= APIVersionTest::Request.new
    request.headers = {}
    request.headers['x-application-id']='test'
    apiVersion = ApiVersion.new("vx")
    result = apiVersion.matches?(request)
    assert_not result
  end


  test "matches v1" do
    request= APIVersionTest::Request.new
    request.headers = {}
    request.headers['x-application-id']='com.secret-service.v1'
    apiVersion = ApiVersion.new("v1")
    result = apiVersion.matches?(request)
    assert result
  end

  class Request
    attr_accessor :headers
  end


end