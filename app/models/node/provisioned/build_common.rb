module Node::Provisioned
  module BuildCommon
    def self.included(base)
      base.send :include, InstanceMethods
      base.class_eval do
        validates_presence_of :domain_id
        validates_presence_of :architecture_id, :operatingsystem_id
        validates_length_of :root_pass, :minimum => 8, :too_short => 'should be 8 characters or more'
        validates_presence_of :ptable_id, :message => "cant be blank unless a custom partition has been defined",
                              :if                  => Proc.new { |host| host.disk.empty? and not defined?(Rake) }
        validates_presence_of :puppet_proxy_id

        before_validation :set_ip_address, :normalize_addresses, :normalize_hostname
        after_validation :ensure_assoications
      end

    end

    module InstanceMethods
      # checks if the host association is a valid association for this host
      def ensure_assoications
        status = true
        %w{ ptable medium architecture}.each do |e|
          value = self.send(e.to_sym)
          next if value.blank?
          unless os.send(e.pluralize.to_sym).include?(value)
            errors.add(e, "#{value} does not belong to #{os} operating system")
            status = false
          end
        end if os

        puppetclasses.uniq.each do |e|
          unless environment.puppetclasses.include?(e)
            errors.add(:puppetclasses, "#{e} does not belong to the #{environment} environment")
            status = false
          end
        end if environment
        status
      end

    end

    def shortname
      domain.nil? ? name : name.chomp("." + domain.name)
    end

    # Called from the host build post install process to indicate that the base build has completed
    # Build is cleared and the boot link and autosign entries are removed
    # A site specific build script is called at this stage that can do site specific tasks
    def built(installed = true)
      self.build = false
      self.installed_at = Time.now.utc if installed
      self.save
    rescue => e
      logger.warn "Failed to set Build on #{self}: #{e}"
      false
    end

    # returns the host correct disk layout, custom or common
    def diskLayout
      @host = self
      pxe_render((disk.empty? ? ptable.layout : disk).gsub("\r", ""))
    end


    def jumpstart?
      operatingsystem.family == "Solaris" and architecture.name =~/Sparc/i rescue false
    end

    # returns a configuration template (such as kickstart) to a given host
    def configTemplate opts = { }
      opts[:kind]               ||= "provision"
      opts[:operatingsystem_id] ||= operatingsystem_id
      opts[:hostgroup_id]       ||= hostgroup_id
      opts[:environment_id]     ||= environment_id

      ConfigTemplate.find_template opts
    end

    def set_ip_address
      self.ip ||= subnet.unused_ip if subnet
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

    def overwrite?
      @overwrite ||= false
    end

    # We have to coerce the value back to boolean. It is not done for us by the framework.
    def overwrite=(value)
      @overwrite = value == "true"
    end

    # converts a name into ip address using DNS.
    # if we are managing DNS, we can query the correct DNS server
    # otherwise, use normal systems dns settings to resolv
    def to_ip_address name_or_ip
      return name_or_ip if name_or_ip =~ Net::Validations::IP_REGEXP
      return dns_ptr_record.dns_lookup(name_or_ip).ip if dns_ptr_record
      # fall back to normal dns resolution
      domain.resolver.getaddress(name_or_ip).to_s
    end

    # align common mac and ip address input
    def normalize_addresses
      # a helper for variable scoping
      helper = []
      [self.mac, self.sp_mac].each do |m|
        unless m.empty?
          m.downcase!
          if m=~/[a-f0-9]{12}/
            m = m.gsub(/(..)/) { |mh| mh + ":" }[/.{17}/]
          elsif mac=~/([a-f0-9]{1,2}:){5}[a-f0-9]{1,2}/
            m = m.split(":").map { |nibble| "%02x" % ("0x" + nibble) }.join(":")
          end
        end
        helper << m
      end
      self.mac, self.sp_mac = helper

      helper = []
      [self.ip, self.sp_ip].each do |i|
        unless i.empty?
          i = i.split(".").map { |nibble| nibble.to_i }.join(".") if i=~/(\d{1,3}\.){3}\d{1,3}/
        end
        helper << i
      end
      self.ip, self.sp_ip = helper
    end

    # ensure that host name is fqdn
    # if the user inputted short name, the domain name will be appended
    # this is done to ensure compatibility with puppet storeconfigs
    def normalize_hostname
      # no hostname was given or a domain was selected, since this is before validation we need to ignore
      # it and let the validations to produce an error
      return if name.empty?

      if domain.nil? and name.match(/\./)
        # try to assign the domain automatically based on our existing domains from the host FQDN
        self.domain = Domain.all.select { |d| name.match(d.name) }.first rescue nil
      else
        # if our host is in short name, append the domain name
        if !new_record? and changed_attributes.keys.include? "domain_id"
          old_domain = Domain.find(changed_attributes["domain_id"])
          self.name.gsub(old_domain.to_s, "")
        end
        self.name += ".#{domain}" unless name =~ /.#{domain}$/i
      end
    end

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

    def can_be_build?
      !build
    end

  end
end
