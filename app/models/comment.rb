class Comment < ApplicationRecord
  belongs_to :post
  broadcasts_to :post
  has_many :reactions, as: :reactable, dependent: :destroy, inverse_of: :reactable

  after_commit :enqueue_notification, on: :create

  private

  def enqueue_notification
    CommentNotificationWorker.perform_async(id)
  end
end
