class Post < ApplicationRecord
    has_rich_text :body
    has_many :comments
    has_many :reactions, as: :reactable, dependent: :destroy, inverse_of: :reactable
end
