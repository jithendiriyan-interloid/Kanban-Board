require "test_helper"

class UserTest < ActiveSupport::TestCase
  def build_user(attributes = {})
    defaults = {
      email: "user-#{SecureRandom.hex(6)}@example.com",
      password: "Password1!",
      password_confirmation: "Password1!",
      confirmed_at: Time.current
    }

    User.new(defaults.merge(attributes))
  end

  test "is valid with valid attributes" do
    assert build_user.valid?
  end

  test "defaults to member role" do
    assert_predicate build_user, :member?
  end

  test "supports owner and admin roles" do
    owner = build_user(role: :owner)
    admin = build_user(role: :admin)

    assert_predicate owner, :owner?
    assert_predicate admin, :admin?
  end

  test "requires email to be unique" do
    user = build_user(email: users(:one).email)

    assert_not user.valid?
    assert_includes user.errors[:email], "has already been taken"
  end

  test "requires password to include a special character" do
    user = build_user(password: "Password12", password_confirmation: "Password12")

    assert_not user.valid?
    assert_includes user.errors[:password], "must include at least one special character"
  end

  test "allows blank alternate email" do
    assert build_user(alternate_email: "").valid?
  end

  test "requires alternate email to be valid when present" do
    user = build_user(alternate_email: "not-an-email")

    assert_not user.valid?
    assert_includes user.errors[:alternate_email], "must be a valid email"
  end

  test "profile is complete when all profile fields are present" do
    user = build_user(
      phone_number: "9876543210",
      address: "123 Kanban Street",
      alternate_email: "alternate@example.com"
    )

    assert_predicate user, :profile_complete?
  end

  test "profile is incomplete when any profile field is missing" do
    user = build_user(
      phone_number: "9876543210",
      alternate_email: "alternate@example.com"
    )

    assert_not user.profile_complete?
  end

  test "can attach an avatar" do
    user = build_user
    user.avatar.attach(
      io: StringIO.new("avatar image"),
      filename: "avatar.jpg",
      content_type: "image/jpeg"
    )

    assert user.avatar.attached?
  end

  test "soft delete marks the user as deleted" do
    user = build_user
    user.save!

    assert_changes -> { user.reload.deleted_at }, from: nil do
      user.soft_delete!
    end
    assert_predicate user, :soft_deleted?
  end

  test "soft deleted users cannot authenticate" do
    user = build_user(deleted_at: Time.current)
    user.save!

    assert_not user.active_for_authentication?
    assert_equal :deleted_account, user.inactive_message
  end
end
