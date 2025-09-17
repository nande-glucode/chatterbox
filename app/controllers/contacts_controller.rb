class ContactsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_contact, only: [:update, :destroy]
  before_action :set_contact_for_removal, only: [:destroy]

  def index
    @contacts = current_user.contacts.includes(:posts).order(:first_name, :last_name)
    @pending_requests = current_user.pending_contact_requests.includes(:requester)
    @sent_requests = current_user.sent_contact_requests.pending.includes(:requested)
  end

  def create
  # Get the requested_id from nested contact params or direct params
  requested_id = params[:contact]&.[](:requested_id) || params[:requested_id]
  
  # Check if requested_id parameter exists
  unless requested_id.present?
    redirect_back(fallback_location: users_path, alert: 'Invalid contact request.')
    return
  end

  begin
    @requested_user = User.find(requested_id)
  rescue ActiveRecord::RecordNotFound
    redirect_back(fallback_location: users_path, alert: 'User not found.')
    return
  end

  # Check if they're trying to add themselves
  if @requested_user == current_user
    redirect_back(fallback_location: users_path, alert: 'You cannot add yourself as a contact.')
    return
  end

  # Check if they're already contacts
  if current_user.contact_with?(@requested_user)
    redirect_back(fallback_location: @requested_user, alert: 'You are already contacts.')
    return
  end

  # Check if a request already exists (in either direction)
  existing_request = current_user.sent_contact_requests.find_by(requested: @requested_user) ||
                    current_user.received_contact_requests.find_by(requester: @requested_user)
                    
  if existing_request
    status_message = case existing_request.status
                    when 'pending'
                      if existing_request.requester == current_user
                        'You already sent a contact request to this user.'
                      else
                        'This user has already sent you a contact request. Check your contacts page.'
                      end
                    when 'declined'
                      'A previous contact request was declined.'
                    else
                      'A contact request already exists between you and this user.'
                    end
    redirect_back(fallback_location: @requested_user, alert: status_message)
    return
  end

  # Create the new contact request
  @contact = current_user.sent_contact_requests.build(requested: @requested_user, status: 'pending')
  
  if @contact.save
    redirect_back(fallback_location: @requested_user, notice: 'Contact request sent successfully!')
  else
    redirect_back(fallback_location: @requested_user, alert: 'Unable to send contact request. Please try again.')
  end
end

  def update
  # Get action_type from nested contact params
  action_type = params[:contact][:action_type] if params[:contact]
  
  Rails.logger.debug "Contact update params: #{params.inspect}"
  puts "Contact update - ID: #{params[:id]}, Action: #{action_type}"
  
  case action_type
  when 'accept'
    Rails.logger.debug "Accepting contact: #{@contact.inspect}"
    @contact.accept!
    redirect_to contacts_path, notice: 'Contact request accepted!'
  when 'decline'
    Rails.logger.debug "Declining contact: #{@contact.inspect}"
    @contact.decline!
    redirect_to contacts_path, notice: 'Contact request declined.'
  else
    Rails.logger.debug "Unknown action_type: #{action_type}"
    redirect_to contacts_path, alert: 'Invalid action.'
  end
end

  def destroy
    @contact.destroy
    redirect_to contacts_path, notice: 'Contact removed.'
  end

  private

  def set_contact
    @contact = current_user.received_contact_requests.find(params[:id])
  end

  def set_contact_for_removal
    @contact = current_user.sent_contact_requests.find(params[:id]) rescue nil
    @contact ||= current_user.received_contact_requests.find(params[:id])
  end
end