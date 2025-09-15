class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  
  has_many :posts, dependent: :destroy
  
  # Contact relationships
  has_many :sent_contact_requests, class_name: 'Contact', 
           foreign_key: 'requester_id', dependent: :destroy
  has_many :received_contact_requests, class_name: 'Contact', 
           foreign_key: 'requested_id', dependent: :destroy
  
  # Accepted contacts (friends)
  has_many :accepted_sent_requests, -> { where(status: 'accepted') }, 
           class_name: 'Contact', foreign_key: 'requester_id'
  has_many :accepted_received_requests, -> { where(status: 'accepted') }, 
           class_name: 'Contact', foreign_key: 'requested_id'
  
  # Users who are contacts (combining both directions)
  has_many :contacts_as_requester, through: :accepted_sent_requests, source: :requested
  has_many :contacts_as_requested, through: :accepted_received_requests, source: :requester
  
  # Validations - make them conditional so existing users aren't forced to update
  validates :first_name, length: { minimum: 2, maximum: 30 }, allow_blank: true
  validates :last_name, length: { minimum: 2, maximum: 30 }, allow_blank: true
  validates :bio, length: { maximum: 500 }
  validates :location, length: { maximum: 100 }
  
  def full_name
    "#{first_name} #{last_name}".strip
  end
  
  def display_name
    if full_name.present?
      full_name
    else
      email.split('@').first.humanize
    end
  end
  
  # Get all contacts (both directions)
  def contacts
    User.where(id: contacts_as_requester.pluck(:id) + contacts_as_requested.pluck(:id))
  end
  
  # Check if users are contacts
  def contact_with?(user)
    return false if user == self
    contacts.include?(user)
  end
  
  # Get pending contact requests sent to this user
  def pending_contact_requests
    received_contact_requests.where(status: 'pending')
  end
  
  # Check contact request status with another user
  def contact_request_status_with(user)
    return nil if user == self
    
    sent_request = sent_contact_requests.find_by(requested: user)
    received_request = received_contact_requests.find_by(requester: user)
    
    return sent_request.status if sent_request
    return received_request.status if received_request
    nil
  end
  
  def profile_complete?
    first_name.present? && last_name.present?
  end
end