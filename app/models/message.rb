class Message < ApplicationRecord
  belongs_to :user
  belongs_to :conversation
  
  validates :content, presence: true, length: { minimum: 1, maximum: 1000 }
  
  scope :recent, -> { order(:created_at) }
  
  after_create :update_conversation_timestamp
  
  private
  
  def update_conversation_timestamp
    conversation.touch
  end
end
