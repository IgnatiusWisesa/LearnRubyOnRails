require "test_helper"

class PostTest < ActiveSupport::TestCase
  def build_post(attrs = {})
    defaults = { title: "Hello", body: "World" }
    Post.create!(defaults.merge(attrs))
  end

  test "is valid with title and body" do
    post = build_post
    assert post.valid?
  end

  test "can have comments" do
    post = build_post
    comment = Comment.create!(content: "Nice!", post: post)
    assert_includes post.comments, comment
  end

  test "can have reactions (polymorphic)" do
    post = build_post
    user = User.create!(
      email: "user-#{SecureRandom.hex(6)}@example.com",
      password: "password",
      confirmed_at: Time.current
    )

    reaction = Reaction.create!(user: user, reactable: post, kind: "like")
    assert_includes post.reactions, reaction
  end

  test "reactions of different kinds can coexist on same post" do
    post = build_post
    user = User.create!(
      email: "user-#{SecureRandom.hex(6)}@example.com",
      password: "password",
      confirmed_at: Time.current
    )

    Reaction.create!(user: user, reactable: post, kind: "like")
    another = Reaction.new(user: user, reactable: post, kind: "love")
    assert another.valid?
  end
end