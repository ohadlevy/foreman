module Expirable
  extend ActiveSupport::Concern

  included do
    scope :expired, -> { where('expires_at <= ?', Time.current) }
  end

  def expires?
    expires_at.present?
  end

  def expired?
    expires? && expires_at <= Time.current
  end
end
