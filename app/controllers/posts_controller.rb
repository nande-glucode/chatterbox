class PostsController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]
  before_action :set_post, only: [:show, :edit, :update, :destroy]
  before_action :check_owner, only: [:edit, :update, :destroy]

  def index
    @posts = Post.all.includes(:user, :category).recent
    @posts = @posts.by_category(params[:category_id]) if params[:category_id].present?
    @posts = @posts.search(params[:search]) if params[:search].present?

    @categories = Category.alphabetical
  end

  def show
  end

  def new
    @post = current_user.posts.build
    @categories = Category.alphabetical
  end

  def create
    @post = current_user.posts.build(post_params)

    if @post.save
      redirect_to @post, notice: 'Post was successfully created.'
    else
      @categories = Category.alphabetical
      render :new
    end
  end

  def edit
    @categories = Category.alphabetical
  end

  def update
    if @post.update(post_params)
      redirect_to @post, notice: 'Post was successfully updated.'
    else
      @categories = Category.alphabetical
      render :edit
    end
  end

  def destroy
    @post.destroy
    redirect_to posts_path, notice: 'Post was successfully destroyed.'
  end

  private

  def set_post
    @post = Post.find(params[:id])
  end

  def post_params
    params.require(:post).permit(:title, :content, :category_id)
  end
  
  def check_owner
    redirect_to posts_path, alert: 'Not authorized' unless @post.user == current_user
  end
end
