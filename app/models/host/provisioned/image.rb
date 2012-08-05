module Host
  module Provisioned
    # Image based provisioning
    # EC2, oVirt Template, OpenStack etc
    module Image

      def self.included(base)
        base.send :include, InstanceMethods
        base.class_eval do

          belongs_to :image
        end
      end

      module InstanceMethods

      end

    end
  end
end
