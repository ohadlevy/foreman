module Orchestration::SSHProvision
  def self.included(base)
    base.send :include, InstanceMethods
    base.class_eval do
      attr_reader :image_id
      after_validation :validate_ssh_provisioning, :queue_ssh_provision
    end
  end

  module InstanceMethods
    def ssh_provision?
      compute_attributes.present? && !(@image_id = compute_attributes[:image_id]).blank?
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

    def queue_compute_update;
    end

    def setSSHProvision
      logger.info "About to start post launch script on #{name}"
      image    = Image.find_by_uuid(image_id)
      template = configTemplate(:kind => "finish")
      @host    = self
      logger.info "generating template to upload to #{name}"
      file = unattended_render_to_temp_file(template.template)

      start_ssh_provisioning image.username, file

    rescue => e
      failure "Failed to start SSH provisioning task for #{name}: #{e}", e.backtrace
    end

    def delSSHProvision
      # since we enable certificates/autosign via here, we also need to make sure we clean it up in case of an error
      if puppetca?
        respond_to?(:initialize_puppetca) && initialize_puppetca && delCertificate && delAutosign
      end
    rescue => e
      failure "Failed to remove certificates for #{name}: #{e}", e.backtrace
    end

    def validate_ssh_provisioning
      return unless ssh_provision?
      return if Rails.env == "test"
      status = true
      unless configTemplate(:kind => "finish")
        status = failure "No finish templates were found for this host, make sure you define at least one in your #{os} settings"
      end
      unless Image.find_by_uuid(image_id)
        status &= failure("failed to find instance image #{image_id}")
      end

      status

    end

    private
    def start_ssh_provisioning username, file

      self.handle_ca
      return false if errors.any?
      logger.info "Revoked old certificates and enabled autosign"
      logger.info "Starting SSH provisioning script - waiting for #{ip} to respond"
      client = Foreman::Provision::SSH.new ip, username, :template => file.path, :uuid => uuid, :key_data => [compute_resource.key_pair.secret]
      logger.info "SSH connection established to #{ip} - executing template"
      if client.deploy!
        self.build        = false
        self.installed_at = Time.now.utc
      else
        raise "Provision script had a non zero exit, removing instance"
      end

    rescue => e
      failure "Failed to launch script on #{name}: #{e}", e.backtrace
    end

  end
end
