# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  about                  :string
#  confirmation_sent_at   :datetime
#  confirmation_token     :string
#  confirmed_at           :datetime
#  current_sign_in_at     :datetime
#  current_sign_in_ip     :string
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  github_uid             :string
#  google_uid             :string
#  last_sign_in_at        :datetime
#  last_sign_in_ip        :string
#  name                   :string
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  sign_in_count          :integer          default(0), not null
#  unconfirmed_email      :string
#  username               :string           default(""), not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_users_on_confirmation_token    (confirmation_token) UNIQUE
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#  index_users_on_username              (username) UNIQUE
#
class User < ApplicationRecord
  devise :database_authenticatable, :confirmable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :omniauthable, omniauth_providers: %i[github google_oauth2]

  attr_accessor :login

  validates :username, length: { in: 2..32 }, uniqueness: { case_sensitive: false },
                       format: { with: /\A\w?\z|\A\w[\w.-]+\z/ } # Assures POSIX.1-2017 compliance
  validates :name, length: { maximum: 64 }
  validates :about, length: { maximum: 256 }

  def self.find_for_database_authentication(warden_conditions)
    conditions = warden_conditions.dup
    login = conditions.delete(:login)
    where(conditions).where(['lower(username) = :value OR lower(email) = :value',
                             { value: login.strip.downcase }]).first
  end

  def self.from_omniauth(auth)
    user = where('github_uid = :uid OR google_uid = :uid OR email = :email', uid: auth.uid,
                                                                             email: auth.info.email)
           .first
    user ||= create_user_from_oauth(auth.info)

    set_oauth_uid(user, auth.provider, auth.uid) if user.persisted?
    user
  end

  def self.create_user_from_oauth(params)
    create do |user|
      user.username = create_username_from_oauth(params.nickname, params.email)
      user.email = params.email
      user.password = Devise.friendly_token[0, 20]
      user.name = params.name
      # user.image = params.image
      user.skip_confirmation!
    end
  end

  def self.create_username_from_oauth(username, email)
    return username if username && where(username:).blank?

    emailname = email.split('@').first
    return emailname if where(username: emailname).blank?

    emailname + Random.new.rand(100..100_000).to_s
  end

  def self.set_oauth_uid(user, provider, uid)
    case provider
    when 'github'
      user.update(github_uid: uid) if user.github_uid.nil?
    when 'google_oauth2'
      user.update(google_uid: uid) if user.google_uid.nil?
    end
  end
end
