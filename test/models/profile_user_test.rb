require "test_helper"

class ProfileUserTest < ActiveSupport::TestCase
  def build_user
    User.create!(
      email: "user-#{SecureRandom.hex(6)}@example.com",
      password: "password",
      confirmed_at: Time.current
    )
  end

  test "auto creates profile for new user (after_create callback)" do
    user = build_user
    assert user.profile_user.present?, "expected user.profile_user to be created automatically"
  end

  test "profile belongs to user (must exist)" do
    user = build_user
    profile = user.profile_user
    assert profile.valid?
    assert_equal user.id, profile.user_id
  end

  test "only one profile per user (uniqueness)" do
    user = build_user
    profile = user.profile_user
    duplicate = ProfileUser.new(user: user)

    assert_not duplicate.valid?, "expected duplicate profile to be invalid"
    assert_includes duplicate.errors[:user_id], "has already been taken"
  end

  test "full_name max length 255" do
    user = build_user
    p = user.profile_user
    p.full_name = "a" * 255
    assert p.valid?, "255 chars should be valid"

    p.full_name = "a" * 256
    assert_not p.valid?, "256 chars should be invalid"
    assert_includes p.errors[:full_name], "is too long (maximum is 255 characters)"
  end

  test "address and full_name can be blank" do
    user = build_user
    p = user.profile_user
    p.full_name = ""
    p.address   = ""
    assert p.valid?
  end

  test "destroying user destroys profile (dependent destroy / FK cascade)" do
    user = build_user
    profile_id = user.profile_user.id
    user.destroy
    assert_not ProfileUser.exists?(profile_id), "profile should be removed when user is destroyed"
  end
end