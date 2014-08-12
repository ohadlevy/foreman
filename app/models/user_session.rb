class UserSession < ActiveRecord::Base
  belongs_to :user
  attr_accessible :accessed_at, :ip, :key, :revoked_at, :user_agent

  before_validation :set_unique_key

  scope :active, lambda {
    { :conditions => ["accessed_at >= ? AND revoked_at == NULL", 2.weeks.ago] }
  }

  def self.authenticate(key)
    self.active.find_by_key(key)
  end

  def revoke!
    self.revoked_at = Time.now
    save!
  end

  def access(request)
    self.accessed_at = Time.now
    self.ip          = request.ip
    self.user_agent  = request.user_agent
    save
  end

  private
  def set_unique_key
    self.key = SecureRandom.urlsafe_base64(32)
  end
end
