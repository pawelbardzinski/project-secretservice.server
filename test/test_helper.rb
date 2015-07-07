ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :all

  def json(body)
    JSON.parse(body, symbolize_names: true)
  end

  def token_header(token)
    ActionController::HttpAuthentication::Token.encode_credentials(token)
  end


  def setWebAPIHeaders(auth_token = nil)
    @request.headers["Accept"] = 'application/json'
    @request.headers["x-application-id"] = 'com.secret-service.ios'
    if auth_token
      @request.headers["x-auth-token"] = auth_token
    end
  end

  def createWebAPIHeaderHash(auth_token = nil)
    if auth_token
      {'Accept'=> Mime::JSON,'Content-Type' => Mime::JSON.to_s,'x-auth-token' => auth_token,'x-application-id' => 'com.secret-service.ios'}
    else
      {'Accept'=> Mime::JSON,'Content-Type' => Mime::JSON.to_s,'x-application-id' => 'com.secret-service.ios'}
    end
  end


  def validates_required(entity,field)
    assert_nil entity.errors.messages[field]
    entity.valid?
    assert_not_nil entity.errors.messages[field]
    assert_not_nil entity.errors.messages[field].grep(/^can't be blank/)
  end
end
