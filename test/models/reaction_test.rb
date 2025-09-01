require "test_helper"

class ReactionTest < ActiveSupport::TestCase
  def build_user
    User.create!(
      email: "user-#{SecureRandom.hex(6)}@example.com",
      password: "password",
      confirmed_at: Time.current
    )
  end

  def build_post
    Post.create!(title: "Hello", body: "World")
  end

  test "valid reaction with kind" do
    user = build_user
    post = build_post
    reaction = Reaction.new(user: user, reactable: post, kind: "like")
    assert reaction.valid?
  end

  test "invalid reaction with unsupported kind" do
    user = build_user
    post = build_post
    reaction = Reaction.new(user: user, reactable: post, kind: "angry")
    assert_not reaction.valid?
    assert_includes reaction.errors[:kind], "is not included in the list"
  end

  test "allows nil kind" do
    user = build_user
    post = build_post
    reaction = Reaction.new(user: user, reactable: post, kind: nil)
    assert reaction.valid?
  end

  test "prevents duplicate reaction per user/reactable/kind" do
    user = build_user
    post = build_post
    Reaction.create!(user: user, reactable: post, kind: "like")
    duplicate = Reaction.new(user: user, reactable: post, kind: "like")
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:user_id], "has reacted to this item"
  end

  test "allows same kind on different reactables" do
    user = build_user
    post = build_post
    comment = Comment.create!(content: "Nice!", post: post)  # ← tanpa user
    Reaction.create!(user: user, reactable: post, kind: "like")
    other = Reaction.new(user: user, reactable: comment, kind: "like")
    assert other.valid?
  end

  test "allows different kinds on the same reactable" do
    user = build_user
    post = build_post
    Reaction.create!(user: user, reactable: post, kind: "like")
    other = Reaction.new(user: user, reactable: post, kind: "love")
    assert other.valid?
  end
end