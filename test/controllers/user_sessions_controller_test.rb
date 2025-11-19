require "test_helper"

class UserSessionsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = User.new(
      name: "Test User",
      email: "testuser@test.com",
      admin: false
    )
    @user.password = "password123"
    @user.password_confirmation = "password123"
    @user.save!
  end

  test "should get login page" do
    get login_path
    assert_response :success
    assert_select "h1", "Log In"
  end

  test "should login with valid credentials" do
    post user_sessions_path, params: {
      user_session: {
        email: @user.email,
        password: "password123"
      }
    }

    assert_redirected_to root_path
    assert_equal "Login successful!", flash[:notice]
  end

  test "should not login with invalid email" do
    post user_sessions_path, params: {
      user_session: {
        email: "wrong@example.com",
        password: "password123"
      }
    }

    assert_response :unprocessable_entity
    assert_equal "Invalid email or password.", flash[:alert]
  end

  test "should not login with invalid password" do
    post user_sessions_path, params: {
      user_session: {
        email: @user.email,
        password: "wrongpassword"
      }
    }

    assert_response :unprocessable_entity
    assert_equal "Invalid email or password.", flash[:alert]
  end

  test "should logout" do
    # First login
    post user_sessions_path, params: {
      user_session: {
        email: @user.email,
        password: "password123"
      }
    }

    # Then logout
    delete logout_path
    assert_redirected_to login_path
    assert_equal "Logout successful!", flash[:notice]
  end

  test "should redirect to stored location after login" do
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

    # Should redirect back to originally requested page
    assert_redirected_to current_user_path
  end
end