class PersonalAccessToken < ActiveRecord::Base
  include Authorizable
  include Expirable

  # validate :add_error

  def add_error
    errors.add(:base, 'this is a warning')
    errors.add(:base, 'this is a another warning')
  end

  belongs_to :user

  audited :except => [:token], :associated_with => :user

  scoped_search :on => :name
  scoped_search :on => :user_id, :complete_enabled => false, :only_explicit => true, :validator => ScopedSearch::Validators::INTEGER

  validates_lengths_from_database

  validates :token, :user_id, :token, presence: true
  validates :name, presence: true, uniqueness: {scope: :user_id}

  scope :active, -> { where(revoked: false).where("expires_at >= ? OR expires_at IS NULL", Time.current) }
  scope :inactive, -> { where(revoked: true).or(where("expires_at < ?", Time.current)) }

  attr_accessor :token_value

  def self.authenticate_user(user, token)
    tokens = self.active.where(:user => user, :token => encrypt_token(user, token))
    return false unless tokens.any?
    tokens.update!(:last_used_at => Time.current)
    true
  end

  def self.token_salt(user)
    Digest::SHA1.hexdigest(user.id.to_s)
  end

  def self.encrypt_token(user, token)
    Digest::SHA1.hexdigest([token, token_salt(user)].join)
  end

  def generate_token
    self.token_value = SecureRandom.urlsafe_base64(nil, false)
    self.token = self.class.encrypt_token(user, token_value)
    token_value
  end

  def revoke!
    update!(revoked: true)
  end

  def revoked?
    !!revoked
  end

  def expires?
    expires_at.present?
  end

  def active?
    !revoked? && !expired?
  end

  def used?
    last_used_at.present?
  end
end
