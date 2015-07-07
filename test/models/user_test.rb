require 'test_helper'
require "active_support/all"

class UserTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end

  test "should be valid" do
    user = User.new(firstname:'test',password:'test1234', email:'formatmobile@example.com', mobile:'212-555-1212')
    user.valid?
  end

  test "should format mobile" do
    user = User.new(firstname:'test',password:'test1234', email:'formatmobile@example.com', mobile:'212-555-1212', role:User::ROLES[:customer][:id])
    user.save!
    assert_equal '2125551212',user.mobile
  end

  test "to_json should filter fields" do
    user = User.new(firstname:'test',password:'test',password_digest:'test_digest')
    user_data= json(user.to_json)

    assert_not_nil user_data[:firstname]
    assert_nil user_data[:password]
    assert_nil user_data[:password_digest]
  end

  test "validate first name required" do
    validates_required User.new(), :firstname
  end


  test "validate email required" do
    validates_required User.new(), :email
  end


  test "validate mobile required for customers" do
    validates_required User.new(), :mobile
  end



  test "validate mobile is valid format" do
    user =  User.new(mobile:"adsfa")
    user.valid?
    assert_not_nil user.errors.messages[:mobile]
    assert_not_nil user.errors.messages[:mobile].grep(/^"is invalid"/)
    user.mobile = "212-555-1212"
    user.valid?
    assert_nil user.errors.messages[:mobile]
  end




  test "validate email is valid format" do
    user =  User.new(email:"adsfa")
    user.valid?
    assert_not_nil user.errors.messages[:email]
    assert_not_nil user.errors.messages[:email].grep(/^"is invalid"/)
    user.email = "test@example.com"
    user.valid?
    assert_nil user.errors.messages[:email]
  end


  test "validate password length" do
    user = User.new(password:"test1")
    assert_nil user.errors.messages[:password]
    user.valid?
    assert_not_nil user.errors.messages[:password]
    assert_not_nil user.errors.messages[:password].grep(/^"is too short (minimum is 6 characters)"/)

    user.password = "test12"
    user.valid?
    assert_nil user.errors.messages[:password]
  end

  test "destroy should just mark as archived" do
    user = User.new(firstname:'test',password:'test1234', email:'formatmobile@example.com', mobile:'212-555-1212', role:User::ROLES[:customer][:id])
    user.save!
    user.reload
    user.archive
    assert_equal true, user.archived
    assert_not_nil User.find(user.id)
  end
end
