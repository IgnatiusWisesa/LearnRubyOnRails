require "test_helper"

class Comments::ReactionsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = User.create!(
      email: "user-#{SecureRandom.hex(6)}@example.com",
      password: "password",
      confirmed_at: Time.current
    )
    @post_record = Post.create!(title: "Hello", body: "World")
    @comment = Comment.create!(content: "Nice!", post: @post_record)
  end

  test "requires login for create" do
    assert_no_difference "Reaction.count" do
      post comment_reactions_path(@comment), params: { kind: "like" }
    end
    assert_response :redirect
    assert_match(/sign_in/, @response.redirect_url)
  end

  test "requires login for destroy" do
    Reaction.create!(user: @user, reactable: @comment, kind: "like")
    assert_no_difference "Reaction.count" do
      delete comment_reactions_path(@comment), params: { kind: "like" }
    end
    assert_response :redirect
    assert_match(/sign_in/, @response.redirect_url)
  end

  test "creates reaction when logged in" do
    log_in(@user)
    assert_difference "Reaction.count", +1 do
      post comment_reactions_path(@comment), params: { kind: "like" }
    end
    assert_response :redirect
  end

  test "is idempotent on create with same kind" do
    log_in(@user)
    post comment_reactions_path(@comment), params: { kind: "like" }
    assert_no_difference "Reaction.count" do
      post comment_reactions_path(@comment), params: { kind: "like" }
    end
    assert_response :redirect
  end

  test "destroys reaction by kind when logged in" do
    log_in(@user)
    Reaction.create!(user: @user, reactable: @comment, kind: "like")
    assert_difference "Reaction.count", -1 do
      delete comment_reactions_path(@comment), params: { kind: "like" }
    end
    assert_response :redirect
  end

  test "does not create with invalid kind" do
    log_in(@user)
    assert_no_difference "Reaction.count" do
      post comment_reactions_path(@comment), params: { kind: "angry" }
    end
    assert_response :redirect
  end
end