require 'test_helper'
require 'sms_sender.rb'

class SMSSenderTest < ActiveSupport::TestCase

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

  # Fake test
  test "reset password sms" do
    greg = users(:greg)
    greg.password_reset_token = "test"

    sender = SMSSender.new
    sender.reset_password_sms(greg)
    assert true
  end
end