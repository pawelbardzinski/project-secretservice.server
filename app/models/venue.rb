class Venue < ActiveRecord::Base
  has_many :products, dependent: :destroy
  has_many :users, dependent: :destroy
  has_many :orders, dependent: :destroy
  validates :name, presence: true
  validates :address_line_1, presence: true
  validates :city, presence: true
  validates :state, presence: true
  validates :zip_code, presence: true

  geocoded_by :full_address

  after_validation :geocode, if: ->(obj){ (obj.address_line_1.present? and obj.address_line_1_changed?) \
                                           or  (obj.address_line_2.present? and obj.address_line_2_changed?) \
                                           or (obj.city.present? and obj.city_changed?) \
                                           or   (obj.zip_code.present? and obj.zip_code_changed?) \
                                           or  (obj.state.present? and obj.state_changed?) \
                                           or  (obj.country.present? and obj.country_changed?) }

  def full_address
    "#{address_line_1}, #{zip_code}, #{city}, #{state}, #{country}"
  end

  def archive
    self.archived = true
    self.save
  end

  def self.find_unarchived(id)
    find_by!(id: id, archived: false)
  end

end
