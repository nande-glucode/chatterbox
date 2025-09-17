class ConversationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_conversation, only: [:show]
  
  def index
    @conversations = current_user.conversations
                                .includes(:users, :messages)
                                .recent
                                .limit(20)
  end
  
  def show
    @messages = @conversation.messages.includes(:user).recent
    @message = Message.new
  end
  
  def start
    Rails.logger.debug "Conversations start params: #{params.inspect}"
    puts "Starting conversation with user_id: #{params[:user_id]}"
    
    unless params[:user_id].present?
      redirect_to conversations_path, alert: 'User not specified.'
      return
    end
    
    @other_user = User.find(params[:user_id])
    
    # Check if users are contacts
    unless current_user.contact_with?(@other_user)
      redirect_to users_path, alert: 'You can only message your contacts.'
      return
    end
    
    # Find existing conversation or create new one
    @conversation = current_user.conversation_with(@other_user)
    if @conversation
      Rails.logger.debug "Found existing conversation: #{@conversation.id}"
    else
      Rails.logger.debug "Creating new conversation"
      @conversation = current_user.create_conversation_with(@other_user)
      Rails.logger.debug "Created conversation: #{@conversation.id}"
    end
    
    redirect_to @conversation
  end
  
  def create
    Rails.logger.debug "Conversations create params: #{params.inspect}"
    puts "Creating conversation with user_id: #{params[:user_id]}"
    
    @other_user = User.find(params[:user_id])
    
    # Check if users are contacts
    unless current_user.contact_with?(@other_user)
      redirect_to users_path, alert: 'You can only message your contacts.'
      return
    end
    
    # Find existing conversation or create new one
    @conversation = current_user.conversation_with(@other_user)
    if @conversation
      Rails.logger.debug "Found existing conversation: #{@conversation.id}"
    else
      Rails.logger.debug "Creating new conversation"
      @conversation = current_user.create_conversation_with(@other_user)
      Rails.logger.debug "Created conversation: #{@conversation.id}"
    end
    
    redirect_to @conversation
  end
  
  private
  
  def set_conversation
    @conversation = current_user.conversations.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to conversations_path, alert: 'Conversation not found.'
  end
end