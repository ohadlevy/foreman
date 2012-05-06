module Node
  module Provisioned
    module Common
      class Jail < ::Safemode::Jail
        allow :name, :diskLayout, :puppetmaster, :puppet_ca_server, :operatingsystem, :os, :environment, :ptable, :hostgroup, :url_for_boot,
              :params, :hostgroup, :domain, :ip, :mac, :shortname, :architecture, :model
      end

      def self.included(base)
        base.send :include, InstanceMethods
        base.class_eval do
          # handles all orchestration of smart proxies.
          include Foreman::Renderer
          include Orchestration
          include HostTemplateHelpers

          before_validation :set_hostgroup_defaults
        end

      end

      module InstanceMethods
        def set_hostgroup_defaults
          return unless hostgroup
          assign_hostgroup_attributes(%w{environment domain puppet_proxy puppet_ca_proxy})
          assign_hostgroup_attributes(%w{operatingsystem medium architecture ptable root_pass subnet})
          assign_hostgroup_attributes(Vm::PROPERTIES) if hostgroup.hypervisor? and not compute_resource_id
        end

        def info

          param = { }
          param["domainname"] = domain.fullname unless domain.nil? or domain.fullname.nil?
          param["root_pw"]    = root_pass unless root_pass.blank?
          param["puppet_ca"]  = puppet_ca_server if puppetca?

          super.merge(param)
        end

        private

        def assign_hostgroup_attributes attrs = []
          attrs.each do |attr|
            eval("self.#{attr.to_s} ||= hostgroup.#{attr.to_s}")
          end
        end

        def my_hosts_conditions(user = User.current)
          return "" unless user.filtering?

          conditions = ""
          if user.domains
            verb       = user.domains_andor == "and" ? "and" : "or"
            conditions = sanitize_sql_for_conditions([" #{verb} (hosts.domain_id in (?))", user.domains.pluck(:id)])
          end

          "#{super} #{conditions}"

        end

      end
    end
  end
end
