class ProfileUser < ApplicationRecord
  belongs_to :user, inverse_of: :profile_user
  validates :full_name, length: { maximum: 255 }, allow_blank: true
end
