require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  test "should get new signup page" do
    get signup_path
    assert_response :success
    assert_select "h1", "Sign Up"
  end

  test "should create user with valid data" do
    assert_difference('User.count', 1) do
      post users_path, params: {
        user: {
          name: "Test User",
          email: "test@example.com",
          password: "password123",
          password_confirmation: "password123"
        }
      }
    end

    assert_redirected_to login_path
    assert_equal "Account created successfully! Please log in.", flash[:notice]
  end

  test "should not create user with invalid email" do
    assert_no_difference('User.count') do
      post users_path, params: {
        user: {
          name: "Test User",
          email: "",
          password: "password123",
          password_confirmation: "password123"
        }
      }
    end

    assert_response :unprocessable_entity
  end

  test "should not create user with mismatched password confirmation" do
    assert_no_difference('User.count') do
      post users_path, params: {
        user: {
          name: "Test User",
          email: "test@example.com",
          password: "password123",
          password_confirmation: "different"
        }
      }
    end

    assert_response :unprocessable_entity
  end

  test "should not create user without name" do
    assert_no_difference('User.count') do
      post users_path, params: {
        user: {
          name: "",
          email: "test@example.com",
          password: "password123",
          password_confirmation: "password123"
        }
      }
    end

    assert_response :unprocessable_entity
  end

  test "should not create user with duplicate email" do
    # Create first user
    user = User.new(
      name: "Existing User",
      email: "existing@example.com",
      admin: false
    )
    user.password = "password123"
    user.password_confirmation = "password123"
    user.save!

    # Try to create duplicate
    assert_no_difference('User.count') do
      post users_path, params: {
        user: {
          name: "New User",
          email: "existing@example.com",
          password: "password123",
          password_confirmation: "password123"
        }
      }
    end

    assert_response :unprocessable_entity
  end
end