class CategoriesController < ApplicationController
  before_action :set_category, only: [:show]

  def index
    @categories = Category.alphabetical.includes(:posts)
  end

  def show
    @posts = @category.posts.includes(:user).recent
    @posts = @posts.search(params[:search]) if params[:search].present?
    @category_name = @category.name
  end

  private

  def set_category
    @category = Category.find(params[:id])
  end
end