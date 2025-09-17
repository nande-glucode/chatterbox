class ConversationChannel < ApplicationCable::Channel
  def subscribed
    conversation = Conversation.find(params[:conversation_id])
    
    # Check if user is participant in this conversation
    if conversation.users.include?(current_user)
      stream_from "conversation_#{conversation.id}"
      Rails.logger.info "User #{current_user.id} subscribed to conversation #{conversation.id}"
    else
      reject
    end
  end

  def unsubscribed
    Rails.logger.info "User unsubscribed from conversation channel"
  end
end