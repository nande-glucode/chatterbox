class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user, only: [:show, :edit, :update]
  before_action :check_owner, only: [:edit, :update]

  def index
    @users = User.where.not(id: current_user.id)
    
    if params[:search].present?
      search_term = "%#{params[:search].downcase}%"
      @users = @users.where(
        "LOWER(first_name) LIKE ? OR LOWER(last_name) LIKE ? OR LOWER(email) LIKE ?", 
        search_term, search_term, search_term
      )
    end
    
    @users = @users.includes(:posts).order(:first_name, :last_name)
  end

  def show
    @posts = @user.posts.includes(:category).recent.limit(5)
    @contact_request_status = current_user.contact_request_status_with(@user)
  end

  def edit
  end

  def update
    if @user.update(user_params)
      redirect_to @user, notice: 'Profile updated successfully.'
    else
      render :edit
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:first_name, :last_name, :bio, :location)
  end

  def check_owner
    redirect_to @user, alert: 'Not authorized.' unless @user == current_user
  end
end