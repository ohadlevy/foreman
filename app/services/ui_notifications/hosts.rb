module UINotifications
  module Hosts
    class Base < UINotifications::Base
      def deliver!
        if audience.nil? || initiator.nil?
          logger.warn("Invalid owner for #{subject}, unable to send notifications")
          # add notification for missing owner
          UINotifications::Hosts::MissingOwner.deliver!(subject)
          return false
        end
        super
      end

      protected

      def audience
        case subject.owner_type
        when 'User'
          ::Notification::AUDIENCE_USER
        when 'Usergroup'
          ::Notification::AUDIENCE_GROUP
        end
      end

      def initiator
        case subject.owner
        when User
          subject.owner
        when Usergroup
          # Usergroup, picking the first user, in theory can look in the audit
          # log to see who set the host on built, but since its a group
          # all of the users are going to get a notification.
          subject.owner.all_users.first
        end
      end
    end
  end
end
