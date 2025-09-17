class Conversation < ApplicationRecord
  has_many :participants, dependent: :destroy
  has_many :users, through: :participants
  has_many :messages, dependent: :destroy
  
  validates :title, length: { maximum: 255 }
  
  scope :recent, -> { order(updated_at: :desc) }
  
  def last_message
    messages.order(:created_at).last
  end
  
  def other_participants(current_user)
    users.where.not(id: current_user.id)
  end
  
  def display_name(current_user)
    if title.present?
      title
    else
      other_participants(current_user).map(&:display_name).join(', ')
    end
  end
  
  def self.between_users(user1, user2)
    joins(:participants)
      .where(participants: { user: [user1, user2] })
      .group('conversations.id')
      .having('COUNT(participants.id) = 2')
      .where(title: [nil, ''])
      .first
  end
end
