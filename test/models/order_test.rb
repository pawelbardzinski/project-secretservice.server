require 'test_helper'

class OrderTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end


  test "validate location required" do
    validates_required Order.new(), :location
  end

end
