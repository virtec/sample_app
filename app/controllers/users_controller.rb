class UsersController < ApplicationController
  before_filter :authenticate, :except => [:show, :new, :create]
  before_filter :correct_user, :only => [:edit, :update]
  before_filter :admin_user,   :only => :destroy
  def index
    @title = "All users"
    @users = User.paginate(:page => params[:page], :per_page => 10)
  end
  def show
    @user = User.find(params[:id])
    @microposts = @user.microposts.paginate(:page => params[:page], :per_page => 10)
    @title = @user.name
  end
  def new
    if signed_in?
      redirect_to(root_path)
    else
      @user = User.new
      @title = "Sign up"
    end
  end
  def create
    if signed_in?
      redirect_to(root_path)
    else
      @user = User.new(params[:user])
      if @user.save
        sign_in @user
        flash[:success] = "Welcome to the Sample App!"
        redirect_to @user
      else
        @title = "Sign up"
        @user.password = ''
        params[:user][:password] = ''
        params[:user][:password_confirmation] = ''
        render :action => 'new', :password => '', 
                                 :password_confirmation => ''
      end
    end
  end
  def edit
    @title = "Edit user"
  end
  def update
    if @user.update_attributes(params[:user])
      flash[:success] = "Profile updated."
      redirect_to @user
    else
      @title = "Edit user"
      render 'edit'
    end
  end
  def destroy
    destroyed_user = User.find(params[:id])
    if destroyed_user.admin? && destroyed_user == current_user
      redirect_to root_path
    else
    User.find(params[:id]).destroy
    flash[:success] = "User #{destroyed_user.name} destroyed."
    redirect_to users_path
    end
  end
  
  def following
    @title = "Following"
    @user = User.find(params[:id])
    @users = @user.following.paginate(:page => params[:page])
    render 'show_follow'
  end

  def followers
    @title = "Followers"
    @user = User.find(params[:id])
    @users = @user.followers.paginate(:page => params[:page])
    render 'show_follow'
  end
  
   private

    def correct_user
      @user = User.find(params[:id])
      redirect_to(root_path) unless current_user?(@user)
    end
    
    def admin_user
      redirect_to(root_path) unless current_user.admin?
    end
end
