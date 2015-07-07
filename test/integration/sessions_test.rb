# require 'test_helper'
#
# class SessionsTest < ActionDispatch::IntegrationTest
#
#    test "should redirect to sign in" do
#     get '/users',{}
#     assert_response :found
#     assert_redirected_to '/sign_in'
#   end
#
#    test "password reset get should return ok with valid token" do
#      user = users(:one)
#      user.password_reset_token = SecureRandom.urlsafe_base64
#      user.password_expires_after = 24.hours.from_now
#      user.save
#      get '/password_reset',user.password_reset_token
#      assert_response :ok
#    end
#
#
#    test "password reset get should redirect to forgot password with expired token" do
#      user = users(:one)
#      user.password_reset_token = SecureRandom.urlsafe_base64
#      user.password_expires_after = 1.minutes.ago
#      user.save
#      get '/password_reset',user.password_reset_token
#      assert_redirected_to :forgot_password
#    end
#
#    test "password reset get should redirect to root if they do not have a valid token" do
#      user = users(:one)
#      user.password_reset_token = SecureRandom.urlsafe_base64
#      user.password_expires_after = 24.hours.from_now
#      get '/password_reset',user.password_reset_token
#      assert_redirected_to :root
#
#    end
#
# end
