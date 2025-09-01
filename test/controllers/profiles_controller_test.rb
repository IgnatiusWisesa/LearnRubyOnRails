require "test_helper"

class ProfilesControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = User.create!(
      email: "user-#{SecureRandom.hex(6)}@example.com",
      password: "password",
      confirmed_at: Time.current
    )
    # after_create callback harus sudah bikin profile_user
    @profile = @user.profile_user
  end

  test "requires login for show" do
    get profile_url
    assert_response :redirect
    assert_match(/sign_in/, @response.redirect_url)
  end

  test "requires login for edit" do
    get edit_profile_url
    assert_response :redirect
    assert_match(/sign_in/, @response.redirect_url)
  end

  test "shows profile when logged in" do
    sign_in @user
    get profile_url
    assert_response :success
  end

  test "edits profile when logged in" do
    sign_in @user
    get edit_profile_url
    assert_response :success
  end

  test "updates profile when logged in" do
    sign_in @user
    patch profile_url, params: {
      profile_user: {
        full_name: "John Doe",
        address:   "Jl. Mawar 123"
      }
    }
    assert_response :redirect
    follow_redirect!
    assert_response :success

    @profile.reload
    assert_equal "John Doe", @profile.full_name
    assert_equal "Jl. Mawar 123", @profile.address
  end

  test "auto builds profile if missing on first edit/update" do
    # Simulasikan user lama tanpa profile (kalau perlu)
    @profile.destroy
    @user.reload
    assert_nil @user.profile_user

    sign_in @user
    patch profile_url, params: { profile_user: { full_name: "Baru", address: "Alamat" } }
    assert_response :redirect

    @user.reload
    assert @user.profile_user.present?
    assert_equal "Baru",   @user.profile_user.full_name
    assert_equal "Alamat", @user.profile_user.address
  end
end