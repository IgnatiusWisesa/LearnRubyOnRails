class Comments::ReactionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_comment

  def create
    reaction = @comment.reactions.find_or_initialize_by(user: current_user, kind: kind_param)
    if reaction.persisted? || reaction.save
      redirect_back fallback_location: @comment.post, notice: "Reacted (#{reaction.kind})"
    else
      redirect_back fallback_location: @comment.post, alert: reaction.errors.full_messages.to_sentence
    end
  end

  def destroy
    reaction = @comment.reactions.find_by!(user: current_user, kind: kind_param)
    reaction.destroy
    redirect_back fallback_location: @comment.post, notice: "Reaction removed"
  end

  private

  def set_comment
    @comment = Comment.find(params[:comment_id])
  end

  def kind_param
    params[:kind].presence || "like"
  end
end