class Product < ActiveRecord::Base
  belongs_to :venue
  validates :name, presence: true
  validates :price, presence: true
  validates :venue_id, presence: true

  def archive
    self.archived = true
    self.save
  end

  def self.find_unarchived(id)
    find_by!(id: id, archived: false)
  end
end
