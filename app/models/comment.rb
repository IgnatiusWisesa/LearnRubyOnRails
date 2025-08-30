class Comment < ApplicationRecord
  belongs_to :post
  broadcasts_to :post
  has_many :reactions, as: :reactable, dependent: :destroy, inverse_of: :reactable
end
