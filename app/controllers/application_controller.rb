class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  # Authentication with Authlogic
  before_action :require_user
  helper_method :current_user_session, :current_user, :logged_in?

  private

  def current_user_session
    return @current_user_session if defined?(@current_user_session)
    @current_user_session = UserSession.find
  end

  def current_user
    return @current_user if defined?(@current_user)
    @current_user = current_user_session&.record
  end

  def logged_in?
    current_user.present?
  end

  def require_user
    unless logged_in?
      store_location
      flash[:alert] = "You must be logged in to access this page."
      redirect_to main_app.login_path
    end
  end

  def require_no_user
    if logged_in?
      flash[:notice] = "You are already logged in."
      redirect_to root_path
    end
  end

  def store_location
    session[:return_to] = request.fullpath if request.get? && !request.xhr?
  end

  def redirect_back_or_default(default = root_path)
    redirect_to(session[:return_to] || default)
    session[:return_to] = nil
  end
end
