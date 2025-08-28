class User < ApplicationRecord
  has_one :profile_user, dependent: :destroy, inverse_of: :user
  after_create -> { create_profile_user }

  # Include default devise modules. Others available are:
  # :lockable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :trackable, :confirmable, :lockable,
         :timeoutable, :omniauthable, omniauth_providers: [:google_oauth2]

  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.email = auth.info.email
      user.password = Devise.friendly_token[0, 20]
      user.confirmed_at = Time.now  # skip confirm kalau pakai confirmable
    end
  end
end
