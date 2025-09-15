class Contact < ApplicationRecord
  belongs_to :requester, class_name: 'User'
  belongs_to :requested, class_name: 'User'
  
  validates :status, presence: true, inclusion: { in: %w[pending accepted declined] }
  validates :requester_id, uniqueness: { scope: :requested_id }
  
  validate :cannot_add_self
  
  scope :pending, -> { where(status: 'pending') }
  scope :accepted, -> { where(status: 'accepted') }
  scope :declined, -> { where(status: 'declined') }
  
  def accept!
    update!(status: 'accepted')
  end
  
  def decline!
    update!(status: 'declined')
  end
  
  private
  
  def cannot_add_self
    errors.add(:requested, "can't add yourself as a contact") if requester_id == requested_id
  end
end