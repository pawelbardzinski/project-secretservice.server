require 'test_helper'

class ProductTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end


  test "destroy should just mark as archived" do
    product = Product.new({name:"Test", price:10, venue_id:1})
    product.save
    product.reload
    product.archive
    assert_equal true, product.archived
    assert_not_nil Product.find(product.id)
  end
end
