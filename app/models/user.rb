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
  
  # Safe validations - only validate if present
  validates :first_name, length: { minimum: 2, maximum: 30 }, allow_blank: true
  validates :last_name, length: { minimum: 2, maximum: 30 }, allow_blank: true
  validates :bio, length: { maximum: 500 }, allow_blank: true
  validates :location, length: { maximum: 100 }, allow_blank: true
  
  # Safe attribute access methods
  def full_name
    fname = (first_name || "").strip
    lname = (last_name || "").strip
    "#{fname} #{lname}".strip
  end
  
  def display_name
    full_name_str = full_name
    if full_name_str.present?
      full_name_str
    else
      email.present? ? email.split('@').first.humanize : "User"
    end
  end
  
  def safe_bio
    bio || ""
  end
  
  def safe_location
    location || ""
  end
  
  # Rest of the methods
  def contacts
    User.where(id: contacts_as_requester.pluck(:id) + contacts_as_requested.pluck(:id))
  end
  
  def contact_with?(user)
    return false if user == self
    contacts.include?(user)
  end
  
  def pending_contact_requests
    received_contact_requests.where(status: 'pending')
  end
  
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