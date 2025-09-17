class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  
  before_action :authenticate_user!
  before_action :set_user_cookie_for_cable
  
  private
  
  def set_user_cookie_for_cable
    if user_signed_in?
      cookies.encrypted[:user_id] = current_user.id
    end
  end
end
