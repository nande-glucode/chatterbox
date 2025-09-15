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
    @requested_user = User.find(params[:requested_id])
    @contact = current_user.sent_contact_requests.build(requested: @requested_user, status: 'pending')
    
    if @contact.save
      redirect_to @requested_user, notice: 'Contact request sent!'
    else
      redirect_to @requested_user, alert: 'Unable to send contact request.'
    end
  end

  def update
    case params[:action_type]
    when 'accept'
      @contact.accept!
      redirect_to contacts_path, notice: 'Contact request accepted!'
    when 'decline'
      @contact.decline!
      redirect_to contacts_path, notice: 'Contact request declined.'
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
    # For removal, we need to find the contact relation in either direction
    @contact = current_user.sent_contact_requests.find(params[:id]) rescue nil
    @contact ||= current_user.received_contact_requests.find(params[:id])
  end
end