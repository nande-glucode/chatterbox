class MessagesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_conversation
  before_action :set_message, only: [:destroy]
  
  def create
    @message = @conversation.messages.build(message_params)
    @message.user = current_user
    
    if @message.save
      # Broadcast the message to all participants
      ActionCable.server.broadcast(
        "conversation_#{@conversation.id}",
        {
          message: ApplicationController.render(
            partial: 'messages/message',
            locals: { message: @message, current_user: current_user }
          ),
          user_id: current_user.id
        }
      )
      
      respond_to do |format|
        format.html { redirect_to @conversation }
        format.js { head :ok }
        format.json { render json: { status: 'success' } }
      end
    else
      respond_to do |format|
        format.html do
          @messages = @conversation.messages.includes(:user).recent
          render 'conversations/show'
        end
        format.js { render json: { errors: @message.errors } }
        format.json { render json: { errors: @message.errors } }
      end
    end
  end
  
  def destroy
    if @message.user == current_user
      @message.destroy
      ActionCable.server.broadcast(
        "conversation_#{@conversation.id}",
        { 
          action: 'delete',
          message_id: @message.id 
        }
      )
    end
    redirect_to @conversation
  end
  
  private
  
  def set_conversation
    @conversation = current_user.conversations.find(params[:conversation_id])
  rescue ActiveRecord::RecordNotFound
    redirect_to conversations_path, alert: 'Conversation not found.'
  end
  
  def set_message
    @message = @conversation.messages.find(params[:id])
  end
  
  def message_params
    params.require(:message).permit(:content)
  end
end