require "test_helper"

class AuthenticationFlowTest < ActionDispatch::IntegrationTest
  def setup
    @user = User.new(
      name: "Test User",
      email: "testuser@test.com",
      admin: false
    )
    @user.password = "password123"
    @user.password_confirmation = "password123"
    @user.save!

    @admin = User.new(
      name: "Admin User",
      email: "adminuser@test.com",
      admin: true
    )
    @admin.password = "password123"
    @admin.password_confirmation = "password123"
    @admin.save!
  end

  test "complete signup, login, and logout flow" do
    # Test signup
    get signup_path
    assert_response :success

    post users_path, params: {
      user: {
        name: "New User",
        email: "new@example.com",
        password: "password123",
        password_confirmation: "password123"
      }
    }
    assert_redirected_to login_path
    follow_redirect!
    assert_response :success

    # Test login with new account
    post user_sessions_path, params: {
      user_session: {
        email: "new@example.com",
        password: "password123"
      }
    }
    assert_redirected_to root_path
    follow_redirect!
    assert_equal "Login successful!", flash[:notice]

    # Test accessing protected page
    get current_user_path
    assert_response :success

    # Test logout
    delete logout_path
    assert_redirected_to login_path
    assert_equal "Logout successful!", flash[:notice]

    # Verify cannot access protected page after logout
    get current_user_path
    assert_redirected_to login_path
    assert_equal "You must be logged in to access this page.", flash[:alert]
  end

  test "admin can access admin panel" do
    # Login as admin
    post user_sessions_path, params: {
      user_session: {
        email: @admin.email,
        password: "password123"
      }
    }
    assert_redirected_to root_path

    # Access admin panel
    get admin_path
    assert_response :success
  end

  test "regular user cannot access admin panel" do
    # Login as regular user
    post user_sessions_path, params: {
      user_session: {
        email: @user.email,
        password: "password123"
      }
    }
    assert_redirected_to root_path
    follow_redirect!

    # Try to access admin panel
    get admin_path
    assert_response :redirect
    assert_equal "http://www.example.com/", response.location
    assert_equal "You must be an admin to access this page.", flash[:alert]
  end

  test "unauthenticated user cannot access protected pages" do
    # Try to access /me without logging in
    get current_user_path
    assert_redirected_to login_path
    assert_equal "You must be logged in to access this page.", flash[:alert]
  end

  test "session persists across requests" do
    # Login
    post user_sessions_path, params: {
      user_session: {
        email: @user.email,
        password: "password123"
      }
    }

    # Make multiple requests
    get current_user_path
    assert_response :success

    get current_user_path
    assert_response :success

    get current_user_path
    assert_response :success

    # Still logged in
    get current_user_path
    assert_response :success
  end

  test "cannot access login page when already logged in" do
    # Login first
    post user_sessions_path, params: {
      user_session: {
        email: @user.email,
        password: "password123"
      }
    }

    # Logout should work
    delete logout_path
    assert_redirected_to login_path

    # Can access login page after logout
    get login_path
    assert_response :success
  end

  test "redirect back to originally requested page after login" do
    # Try to access protected page
    get current_user_path
    assert_redirected_to login_path

    # Login
    post user_sessions_path, params: {
      user_session: {
        email: @user.email,
        password: "password123"
      }
    }

    # Should redirect back to current_user_path
    assert_redirected_to current_user_path
  end
end