class Category < ApplicationRecord
  has_many :posts, dependent: :destroy
  
  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates :description, presence: true
  
  scope :alphabetical, -> { order(:name) }
  
  def to_s
    name
  end
end
