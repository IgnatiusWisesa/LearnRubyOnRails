class Posts::ReactionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_post

  def create
    reaction = @post.reactions.find_or_initialize_by(user: current_user, kind: kind_param)
    if reaction.persisted? || reaction.save
      redirect_back fallback_location: @post, notice: "Reacted (#{reaction.kind})"
    else
      redirect_back fallback_location: @post, alert: reaction.errors.full_messages.to_sentence
    end
  end

  def destroy
    reaction = @post.reactions.find_by!(user: current_user, kind: kind_param)
    reaction.destroy
    redirect_back fallback_location: @post, notice: "Reaction removed"
  end

  private

  def set_post
    @post = Post.find(params[:post_id])
  end

  def kind_param
    params[:kind].presence || "like"
  end
end