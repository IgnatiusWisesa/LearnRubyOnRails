require "test_helper"

class UserTest < ActiveSupport::TestCase
  def build_email
    "user-#{SecureRandom.hex(6)}@example.com"
  end

  def auth_hash(provider: "google_oauth2", uid: SecureRandom.hex(8), email: build_email)
    OmniAuth::AuthHash.new(
      provider: provider,
      uid: uid,
      info: OmniAuth::AuthHash::InfoHash.new(email: email)
    )
  end

  test "is valid with email and password" do
    user = User.new(email: build_email, password: "password", confirmed_at: Time.current)
    assert user.valid?, "expected user to be valid with email/password"
    assert user.save
  end

  test "email must be unique" do
    email = build_email
    User.create!(email: email, password: "password", confirmed_at: Time.current)

    dup = User.new(email: email, password: "password", confirmed_at: Time.current)
    assert_not dup.valid?, "duplicate email should be invalid"
    assert_includes dup.errors[:email], "has already been taken"
  end

  test "creates profile_user after create" do
    user = User.create!(email: build_email, password: "password", confirmed_at: Time.current)
    assert user.profile_user.present?, "expected profile_user to be auto-created"
  end

  test ".from_omniauth creates a new user with email and confirmed_at" do
    auth = auth_hash
    user = User.from_omniauth(auth)

    assert user.persisted?, "from_omniauth should persist user"
    assert_equal auth.info.email, user.email
    assert user.confirmed_at.present?, "from_omniauth should set confirmed_at"
  end

  test ".from_omniauth is idempotent for same provider+uid" do
    uid = SecureRandom.hex(8)
    email = build_email
    auth1 = auth_hash(uid: uid, email: email)
    user1 = User.from_omniauth(auth1)

    auth2 = auth_hash(uid: uid, email: email)
    user2 = User.from_omniauth(auth2)

    assert_equal user1.id, user2.id, "should return existing user for same provider+uid"
  end
end