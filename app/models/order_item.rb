class OrderItem < ActiveRecord::Base
  belongs_to :order
  belongs_to :product


  def to_json(options={})
    options[:methods] ||= :product_name
    super(options)
  end

  def as_json(options = { })
    options[:methods] ||= :product_name
    super(options)
  end

  def product_name
    self.product.name if self.product
  end

end
