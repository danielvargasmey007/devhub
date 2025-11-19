# UserSessionsController handles login and logout
class UserSessionsController < ApplicationController
  skip_before_action :require_user, only: [ :new, :create ]
  skip_before_action :verify_authenticity_token, only: [ :create, :destroy ], if: -> { request.format.json? }

  def new
    @user_session = UserSession.new

    respond_to do |format|
      format.html
      format.json { render json: { error: "Please login" }, status: :unauthorized }
    end
  end

  def create
    @user_session = UserSession.new(user_session_params.to_h)

    if @user_session.save
      respond_to do |format|
        format.html do
          flash[:notice] = "Login successful!"
          redirect_back_or_default root_path
        end
        format.json { head :no_content }
      end
    else
      respond_to do |format|
        format.html do
          flash.now[:alert] = "Invalid email or password."
          render :new, status: :unprocessable_entity
        end
        format.json { render json: { error: "Invalid email or password" }, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    current_user_session&.destroy

    respond_to do |format|
      format.html do
        flash[:notice] = "Logout successful!"
        redirect_to login_path
      end
      format.json { head :no_content }
    end
  end

  private

  def user_session_params
    params.require(:user_session).permit(:email, :password, :remember_me)
  end
end
