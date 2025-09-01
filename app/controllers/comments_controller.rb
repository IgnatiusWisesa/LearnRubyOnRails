class CommentsController < ApplicationController
  before_action :set_post,    only: :create
  before_action :set_comment, only: %i[update destroy]

  def create
    @comment = @post.comments.build(comment_params)
    if @comment.save
      redirect_to @post, notice: "Comment created"
    else
      redirect_to @post, alert: @comment.errors.full_messages.to_sentence
    end
  end

  def update
    if @comment.update(comment_params)
      redirect_to @comment.post, notice: "Comment updated"
    else
      redirect_to @comment.post, alert: @comment.errors.full_messages.to_sentence
    end
  end

  def destroy
    post = @comment.post
    @comment.destroy
    redirect_to post, notice: "Comment deleted"
  end

  private

  def set_post
    @post = Post.find(params[:post_id])
  end

  def set_comment
    @comment = Comment.find(params[:id])
  end

  def comment_params
    params.require(:comment).permit(:content)
  end
end
