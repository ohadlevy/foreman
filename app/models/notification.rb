class Notification < ActiveRecord::Base
  belongs_to :notification_type
  belongs_to :initiator, :class_name => User, :foreign_key => 'user_id'
  belongs_to :subject, :polymorphic => true
  has_many :notification_recipients, :dependent => :delete_all
  has_many :recipients, :class_name => User, :through => :notification_recipients, :source => :user

  validates :notification_type, :presence => true
  validates :initiator, :presence => true
  validates :subject, :presence => true, :allow_nil => true
  before_create :calcuate_expiry, :set_notification_recipients
  after_commit :emit_message, :on => :create

  scope :active, -> { where('expired_at >= :now', {:now => Time.now.utc}) }
  scope :expired, -> { where('expired_at < :now', {:now => Time.now.utc}) }

  def type=(type)
    self.notification_type = NotificationType.find_by_name!(type)
  end

  def expired?
    Time.now.utc > expired_at
  end

  private

  def calcuate_expiry
    self.expired_at = Time.now.utc + notification_type.expires_in
  end

  def set_notification_recipients
    subscribers = notification_type.subscriber_ids(initiator, subject)
    self.notification_recipients.build subscribers.map{|id| { :user_id => id}}
  end

  def emit_message
    # notification_recipients.each do |notice|
    # ActionCable.server.broadcast("notifications_#{notice.user_id}", notice.payload)
    # end
  end
end
