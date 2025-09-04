# test/controllers/posts/reactions_controller_test.rb
require "test_helper"

class Posts::ReactionsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = User.create!(
      email: "user-#{SecureRandom.hex(6)}@example.com",
      password: "password",
      confirmed_at: Time.current
    )
    @post_record = Post.create!(title: "Hello", body: "World")
  end

  test "requires login for create" do
    assert_no_difference "Reaction.count" do
      post post_reactions_path(@post_record), params: { kind: "like" }
    end
    assert_response :redirect
    assert_match(/sign_in/, @response.redirect_url)
  end

  test "requires login for destroy" do
    Reaction.create!(user: @user, reactable: @post_record, kind: "like")
    assert_no_difference "Reaction.count" do
      delete post_reactions_path(@post_record), params: { kind: "like" }
    end
    assert_response :redirect
    assert_match(/sign_in/, @response.redirect_url)
  end

  test "creates reaction when logged in" do
    log_in(@user)
    assert_difference "Reaction.count", +1 do
      post post_reactions_path(@post_record), params: { kind: "like" }
    end
    assert_response :redirect
  end

  test "is idempotent on create with same kind" do
    log_in(@user)
    post post_reactions_path(@post_record), params: { kind: "like" }
    assert_no_difference "Reaction.count" do
      post post_reactions_path(@post_record), params: { kind: "like" }
    end
    assert_response :redirect
  end

  test "destroys reaction by kind when logged in" do
    log_in(@user)
    Reaction.create!(user: @user, reactable: @post_record, kind: "like")
    assert_difference "Reaction.count", -1 do
      delete post_reactions_path(@post_record), params: { kind: "like" }
    end
    assert_response :redirect
  end

  test "does not create with invalid kind" do
    log_in(@user)
    assert_no_difference "Reaction.count" do
      post post_reactions_path(@post_record), params: { kind: "angry" }
    end
    assert_response :redirect
  end
end