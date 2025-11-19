# config/initializers/session_store.rb

# For development with cross-origin requests between localhost:5173 and localhost:3000
# We need same_site: :none but Chrome/Firefox require secure: true with it
# However, we can set secure: false in development if using localhost
if Rails.env.development?
  Rails.application.config.session_store :cookie_store,
    key: "_devhub_session",
    same_site: :none,
    secure: false,
    httponly: false  # Allow JavaScript to read for debugging
else
  Rails.application.config.session_store :cookie_store,
    key: "_devhub_session",
    same_site: :none,
    secure: true,    # Required in production
    httponly: true
end