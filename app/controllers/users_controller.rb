# UsersController handles user registration and profile
class UsersController < ApplicationController
  skip_before_action :require_user, only: [ :new, :create ]
  before_action :require_user, only: [ :me ]

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params.except(:password, :password_confirmation))
    @user.password = user_params[:password]
    @user.password_confirmation = user_params[:password_confirmation]

    if @user.save
      flash[:notice] = "Account created successfully! Please log in."
      redirect_to login_path
    else
      flash.now[:alert] = "There was a problem creating your account."
      render :new, status: :unprocessable_entity
    end
  end

  # Current user endpoint for future React integration
  def me
    # Currently just renders a simple view
    # Future: respond_to { |format| format.json { render json: current_user } }
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end
end