class Order < ActiveRecord::Base
  has_many :order_items, dependent: :destroy
  belongs_to :user
  belongs_to :venue

  validates :user_id, presence: true
  validates :venue_id, presence: true
  validates :order_status, presence: true
  validates :location, presence: true


  validates_associated :order_items
  accepts_nested_attributes_for :order_items



  STATUSES = {
      :submitted => {:id => 1, :name => "submitted", :label => "submitted"},
      :ready_for_pickup => {:id => 2, :name => "pickup", :label => "Ready for pickup"},
      :delivering => {:id => 3, :name => "delivering", :label => "It's on the way"},
      :completed => {:id => 4, :name => "completed", :label => "Completed"},
      :cancelled => {:id => 5, :name => "cancelled", :label => "Cancelled"}
  }

  def cancel
    self.order_status = Order::STATUSES[:cancelled][:id]
    self.save
  end

  def to_json(options={})
    options[:methods] ||= :full_name
    super(options)
  end


  def full_name
    self.user.firstname + " " + self.user.lastname if self.user
  end

end
