class PaymentOption < ActiveRecord::Base
  belongs_to :user
  belongs_to :venue
  validates :last_4, presence: true
  validates :payment_identifier, presence: true
  validates :venue_id, presence: true, if: :is_venue_required
  validates :payment_type, presence: true


  PAYMENT_TYPES = {
      :credit_card => {:id => 1, :name => "credit card", :label => "Credit Card"},
      :membership_id => {:id => 2, :name => "membershipid", :label => "Memberhship Id"}
  }

  def is_venue_required
    self.payment_type == PaymentOption::PAYMENT_TYPES[:membership_id][:id]
  end

  def set_last_4(payment_identifier)
    length = payment_identifier.length
    if(payment_identifier.length>4)
      self.last_4 = payment_identifier[(length-4)..length]
    else
      self.last_4 = payment_identifier
    end

  end


end
