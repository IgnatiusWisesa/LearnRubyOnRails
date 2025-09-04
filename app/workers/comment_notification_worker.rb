class CommentNotificationWorker
  include Sidekiq::Worker
  sidekiq_options queue: :mailers, retry: 10, backtrace: true

  def perform(comment_id)
    comment = Comment.find_by(id: comment_id)
    return unless comment

    post = comment.post
    recipient =
      (post.respond_to?(:user) && post.user&.email).presence ||
      Rails.application.credentials.dig(:notifications, :default_recipient) ||
      ENV["DEFAULT_NOTIFICATION_EMAIL"]

    unless recipient.present?
      Rails.logger.info("[CommentNotificationWorker] skip: no recipient for comment ##{comment_id}")
      return
    end

    CommentMailer.comment_created(comment.id, to: recipient).deliver_now
  end
end