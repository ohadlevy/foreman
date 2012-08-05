module Host
  module Provisioned
    # Build based provisioning
    # Kickstart, Preseed etc.
    module Build

      def self.included(base)
        base.send :include, InstanceMethods
        base.class_eval do

          validates_presence_of :ptable_id, :message => "cant be blank unless a custom partition has been defined",
                                :if                  => Proc.new { |host| host.disk.empty? and not defined?(Rake) }
        end

      end

      module InstanceMethods

        # returns the host correct disk layout, custom or common
        def diskLayout
          @host = self
          pxe_render((disk.empty? ? ptable.layout : disk).gsub("\r",""))
        end

        # Called from the host build post install process to indicate that the base build has completed
        # Build is cleared and the boot link and autosign entries are removed
        # A site specific build script is called at this stage that can do site specific tasks
        def built(installed = true)
          self.build        = false
          self.installed_at = Time.now.utc if installed
          self.save
        rescue => e
          logger.warn "Failed to set Build on #{self}: #{e}"
          false
        end

        # Called by build link in the list
        # Build is set
        # The boot link and autosign entry are created
        # Any existing puppet certificates are deleted
        # Any facts are discarded
        def setBuild
          clearFacts
          clearReports
          self.build = true
          self.save
          errors.empty?
        end
      end

    end
  end
end