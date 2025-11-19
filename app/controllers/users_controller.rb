# UsersController handles user registration and profile
class UsersController < ApplicationController
  skip_before_action :require_user, only: [ :new, :create ]
  before_action :require_user, only: [ :me ]
  skip_before_action :verify_authenticity_token, only: [ :create, :me ], if: -> { request.format.json? }

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params.except(:password, :password_confirmation))
    @user.password = user_params[:password]
    @user.password_confirmation = user_params[:password_confirmation]

    if @user.save
      respond_to do |format|
        format.html do
          flash[:notice] = "Account created successfully! Please log in."
          redirect_to login_path
        end
        format.json { head :created }
      end
    else
      respond_to do |format|
        format.html do
          flash.now[:alert] = "There was a problem creating your account."
          render :new, status: :unprocessable_entity
        end
        format.json { render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  # Current user endpoint for React integration
  def me
    if current_user
      render json: {
        id: current_user.id,
        name: current_user.name,
        email: current_user.email,
        admin: current_user.admin
      }
    else
      render json: { error: "Not authenticated" }, status: :unauthorized
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end
end
