require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  def create_user(attributes = {})
    defaults = {
      email: "user-#{SecureRandom.hex(6)}@example.com",
      password: "Password1!",
      password_confirmation: "Password1!",
      confirmed_at: Time.current
    }

    User.create!(defaults.merge(attributes))
  end

  test "redirects guests to the sign in page" do
    get root_path

    assert_redirected_to new_user_session_path
  end

  test "shows profile form for signed in user with incomplete profile" do
    sign_in create_user

    get root_path

    assert_response :success
    assert_includes response.body, "Complete your profile"
  end

  test "shows saved profile information when profile is complete" do
    sign_in create_user(
      phone_number: "9876543210",
      alternate_email: "alternate@example.com",
      address: "123 Kanban Street"
    )

    get root_path

    assert_response :success
    assert_includes response.body, "Profile information"
    assert_includes response.body, "9876543210"
    assert_includes response.body, "alternate@example.com"
  end

  test "updates the current user's profile" do
    user = create_user
    sign_in user

    patch profile_path, params: {
      user: {
        phone_number: "1234567890",
        alternate_email: "profile@example.com",
        address: "456 Board Lane"
      }
    }

    assert_redirected_to root_path
    assert_equal "Your profile information was saved.", flash[:notice]
    user.reload
    assert_equal "1234567890", user.phone_number
    assert_equal "profile@example.com", user.alternate_email
    assert_equal "456 Board Lane", user.address
  end

  test "updates the current user's avatar from the profile form" do
    user = create_user
    sign_in user

    patch profile_path, params: {
      user: {
        avatar: Rack::Test::UploadedFile.new(
          Rails.root.join("app/assets/images/default_avatar.jpg"),
          "image/jpeg"
        )
      }
    }

    assert_redirected_to root_path
    assert user.reload.avatar.attached?
  end

  test "renders profile form again when profile data is invalid" do
    user = create_user(alternate_email: "old@example.com")
    sign_in user

    patch profile_path, params: {
      user: {
        phone_number: "1234567890",
        alternate_email: "invalid-email",
        address: "456 Board Lane"
      }
    }

    assert_response :unprocessable_entity
    assert_includes response.body, "Alternate email must be a valid email"
    assert_equal "old@example.com", user.reload.alternate_email
  end

  test "skips the profile form for the session" do
    sign_in create_user

    post skip_profile_path

    assert_redirected_to root_path
    assert_equal "You can add your profile information later.", flash[:notice]

    follow_redirect!
    assert_includes response.body, "Profile information"
    assert_not_includes response.body, "Complete your profile"
  end

  test "soft deletes the current user and signs them out" do
    user = create_user
    sign_in user

    delete delete_profile_path

    assert_redirected_to new_user_session_path
    assert_equal "Your account has been deleted.", flash[:notice]
    assert_predicate user.reload, :soft_deleted?
  end
end
