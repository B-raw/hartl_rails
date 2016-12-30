class User < ApplicationRecord
  attr_accessor :remember_token

  before_save { self.email = email.downcase }

  validates(:name, { presence: true, length: { maximum: 50 }})

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  validates(:email, { presence: true,
                      length: { maximum: 255 },
                      format: { with: VALID_EMAIL_REGEX },
                      uniqueness: { case_sensitive: false } })

  validates(:password, { length: { minimum: 6 },
                         presence: true,
                         allow_nil: true })

  has_secure_password

  # Returns the hash digest of the given string.
  def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                  BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  # Remembers a user in the database for use in persistent sessions.
  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
  end

  # Returns true if the given token matches the digest.
  def authenticated?(remember_token)
    return false if remember_digest.nil?
    BCrypt::Password.new(remember_digest).is_password?(remember_token)
  end

  def User.new_token
    SecureRandom.urlsafe_base64
  end

  # Forgets a user.
  def forget
    update_attribute(:remember_digest, nil)
  end
end

=begin - COOKIE PATHWAY
  when user is created, there is no remember token
  when user logs in and a new session is created, "remember user" is called
  remember user calls user.remember + creates permanent cookies for 1) user_id (signed to secure) + remember_token
  user.remember creates a new_token which is the remember_token then adds this remember_token digest into the database
  this remember creates a remember token which is saved as a remember digest in the user table

  now when logged_in or current_user is called, it first looks for a session, then for a user_id cookie
  if there is a user_id cookie, it searches the database for that user
  it then authenticates the remember_token cookie with the user database digest, and if authentic, logs user in
=end
