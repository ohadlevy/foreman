require 'test_helper'

class UINotificationsHostsMissingOwnerTest < ActiveSupport::TestCase
  test 'add missing host owner notification' do
    assert_difference("Notification.where(:subject => host).count", 1) do
      UINotifications::Hosts::MissingOwner.deliver!(host)
    end
  end

  test 'multiple build events should update current build notification' do
    assert_difference("Notification.where(:subject => host).count", 1) do
      UINotifications::Hosts::MissingOwner.deliver!(host)
      UINotifications::Hosts::MissingOwner.deliver!(host)
    end
  end
  private

  def host
    @host ||= FactoryGirl.create(:host, :managed)
  end

  def blueprint
    @blueprint ||= NotificationBlueprint.find_by(name: 'host_missing_owner')
  end
end
