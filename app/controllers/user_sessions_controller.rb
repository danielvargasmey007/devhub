# UserSessionsController handles login and logout
class UserSessionsController < ApplicationController
  skip_before_action :require_user, only: [ :new, :create ]

  def new
    @user_session = UserSession.new
  end

  def create
    @user_session = UserSession.new(user_session_params.to_h)

    if @user_session.save
      flash[:notice] = "Login successful!"
      redirect_back_or_default root_path
    else
      flash.now[:alert] = "Invalid email or password."
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    current_user_session&.destroy
    flash[:notice] = "Logout successful!"
    redirect_to login_path
  end

  private

  def user_session_params
    params.require(:user_session).permit(:email, :password, :remember_me)
  end
end