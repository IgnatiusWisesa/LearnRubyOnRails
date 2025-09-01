require "test_helper"

class CommentTest < ActiveSupport::TestCase
  def build_post
    Post.create!(title: "Hello", body: "World")
  end

  test "is valid with content and post" do
    post = build_post
    comment = Comment.new(content: "Nice post!", post: post)
    assert comment.valid?
  end

  test "is invalid without post" do
    comment = Comment.new(content: "No post attached")
    assert_not comment.valid?
    assert_includes comment.errors[:post], "must exist"
  end

  test "can have reactions" do
    post = build_post
    comment = Comment.create!(content: "Hello!", post: post)
    user = User.create!(
      email: "user-#{SecureRandom.hex(6)}@example.com",
      password: "password",
      confirmed_at: Time.current
    )

    reaction = Reaction.create!(user: user, reactable: comment, kind: "like")
    assert_includes comment.reactions, reaction
  end
end