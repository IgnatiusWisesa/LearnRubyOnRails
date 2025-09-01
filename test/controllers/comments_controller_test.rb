require "test_helper"

class CommentsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @post_record = Post.create!(title: "Hello", body: "World")
  end

  test "creates comment (nested under post) without login" do
    assert_difference "Comment.count", +1 do
      post post_comments_path(@post_record), params: { comment: { content: "Nice!" } }
    end
    assert_response :redirect
    follow_redirect!
    assert_response :success
  end

  test "updates comment by id (top-level route) without login" do
    comment = Comment.create!(content: "Old", post: @post_record)

    patch comment_path(comment), params: { comment: { content: "New" } }
    assert_response :redirect
    comment.reload
    assert_equal "New", comment.content
  end

  test "destroys comment by id (top-level route) without login" do
    comment = Comment.create!(content: "To be deleted", post: @post_record)

    assert_difference "Comment.count", -1 do
      delete comment_path(comment)
    end
    assert_response :redirect
  end
end