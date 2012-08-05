module Host
  module Provisioned
    class Base < Host::Base
      include Foreman::Renderer
      include Orchestration
      include HostTemplateHelpers

      belongs_to :sp_subnet, :class_name => "Subnet"

      class Jail < ::Safemode::Jail
        allow :name, :diskLayout, :puppetmaster, :puppet_ca_server, :operatingsystem, :os, :environment, :ptable, :hostgroup, :url_for_boot,
              :params, :info, :hostgroup, :compute_resource, :domain, :ip, :mac, :shortname, :architecture, :model, :certname, :capabilities,
              :provider
      end

      alias_attribute :os, :operatingsystem
      alias_attribute :arch, :architecture

      before_validation :set_certname, :if => Proc.new { Setting[:use_uuid_for_certificates] } if SETTINGS[:unattended]

      validates_uniqueness_of  :sp_mac, :allow_nil => true, :allow_blank => true
      validates_uniqueness_of  :sp_name, :sp_ip, :allow_blank => true, :allow_nil => true
      validates_presence_of    :architecture_id, :operatingsystem_id, :domain_id
      validates_length_of      :root_pass, :minimum => 8,:too_short => 'should be 8 characters or more'
      validates_format_of      :sp_mac,    :with => Net::Validations::MAC_REGEXP, :allow_nil => true, :allow_blank => true
      validates_format_of      :sp_ip,     :with => Net::Validations::IP_REGEXP, :allow_nil => true, :allow_blank => true
      validates_format_of      :serial,    :with => /[01],\d{3,}n\d/, :message => "should follow this format: 0,9600n8", :allow_blank => true, :allow_nil => true




      # Cleans Certificate and enable Autosign
      # Called after a host is given their provisioning template
      # Returns : Boolean status of the operation
      def handle_ca
        return true if Rails.env == "test"
        return true unless Setting[:manage_puppetca]
        if puppetca?
          respond_to?(:initialize_puppetca) && initialize_puppetca && delCertificate && setAutosign
        end
      end

      # returns a configuration template (such as kickstart) to a given host
      def configTemplate opts = {}
        opts[:kind]               ||= "provision"
        opts[:operatingsystem_id] ||= operatingsystem_id
        opts[:hostgroup_id]       ||= hostgroup_id
        opts[:environment_id]     ||= environment_id

        ConfigTemplate.find_template opts
      end

      def can_be_build?
         SETTINGS[:unattended] and capabilities.include?(:build) ? build == false : false
      end

      def overwrite?
        @overwrite ||= false
      end

      # We have to coerce the value back to boolean. It is not done for us by the framework.
      def overwrite=(value)
        @overwrite = value == "true"
      end

      protected

      def facts_field_to_import
        Setting[:ignore_puppet_facts_for_provisioning] ?  super - [:mac, :ip] : super
      end

    end
  end
end