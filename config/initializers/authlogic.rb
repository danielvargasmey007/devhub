# config/initializers/authlogic.rb

# Configure Authlogic for API usage
Authlogic::Session::Base.class_eval do
  # Disable origin verification for cross-origin requests
  # This is safe when using CORS properly (which we are)
  def check_requests_from_same_origin?
    false
  end
end