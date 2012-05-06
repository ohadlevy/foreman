module Orchestration::SSHProvision
  def self.included(base)
    base.send :include, InstanceMethods
    base.class_eval do
      attr_accessor :image_id
      after_validation :queue_ssh_provision
    end
  end

  module InstanceMethods
    def ssh_provision?
      compute_attributes.present? && !(image_id = compute_attributes[:image_id]).blank?
    end

    protected
    def queue_ssh_provision
      return unless ssh_provision? and errors.empty?
      new_record? ? queue_ssh_provision_create : queue_compute_update
    end

    # I guess this is not going to happen on create as we might not have an ip address yet.
    def queue_ssh_provision_create
      queue.create(:name   => "Settings up ssh_provision instance #{self}", :priority => 2000,
                   :action => [self, :setSSHProvision])
    end

    def setSSHProvision
      logger.info "About to start post launch script on #{name}"
      ssh_provision = SSHProvision.find_by_uuid(ssh_provision_id)
      @host = self
      template_filename = unattended_render_to_temp_file(configTemplate(:kind => "finish").template)

      start_ssh_provisioning id, image.username, template_filename

    rescue => e
      failure "Failed to start SSH provisioning task for #{name}: #{e}", e.backtrace
    end

    def delSSHProvision; end


    private

    def start_ssh_provisioning id, username, filename

      host = Host.find(id)

      host.handle_ca
      client = Foreman::Provision::SSH.new host.ip, username, :template => filename, :uuid => host.uuid, :key_data => host.compute_resource.key_pair.secret
      host.built client.deploy!

    rescue => e
      failure "Failed to launch script on #{name}: #{e}", e.backtrace
    end

  end
end
