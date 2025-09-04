class CommentMailer < ApplicationMailer
  def comment_created(comment_id, to:)
    @comment = Comment.find(comment_id)
    @post = @comment.post
    mail(to: to, subject: "[Blog] New Comment on: #{@post.title}")
  end
end