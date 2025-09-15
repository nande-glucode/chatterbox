class Post < ApplicationRecord
  belongs_to :user
  belongs_to :category, optional: true
  
  validates :title, presence: true, length: { minimum: 5, maximum: 255 }
  validates :content, presence: true, length: { minimum: 10 }
  
  scope :by_category, ->(category_id) { where(category_id: category_id) if category_id.present? }
  scope :search_by_title, ->(query) { where("title ILIKE ?", "%#{query}%") if query.present? }
  scope :search_by_content, ->(query) { where("content ILIKE ?", "%#{query}%") if query.present? }
  scope :recent, -> { order(created_at: :desc) }
  
  def self.search(query)
    return all if query.blank?
    
    search_by_title(query).or(search_by_content(query))
  end
end
