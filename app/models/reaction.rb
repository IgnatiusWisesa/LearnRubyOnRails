class Reaction < ApplicationRecord
  KINDS = %w[like love clap].freeze

  belongs_to :user
  belongs_to :reactable, polymorphic: true, inverse_of: :reactions

  validates :kind, inclusion: { in: KINDS }, allow_nil: true 
  validates :user_id, uniqueness: {
    scope: %i[reactable_type reactable_id kind],
    message: "has reacted to this item"
  }
end
