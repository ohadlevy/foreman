require 'facts_importer'

class Host
  belongs_to :compute_resource

  include Hostext::Search
  include HostCommon


  attr_reader :cached_host_params, :cached_lookup_keys_params

  scope :my_hosts, lambda {
    user                 = User.current
    return { :conditions => "" } if user.admin? # Admin can see all hosts

    owner_conditions             = sanitize_sql_for_conditions(["((hosts.owner_id in (?) AND hosts.owner_type = 'Usergroup') OR (hosts.owner_id = ? AND hosts.owner_type = 'User'))", user.my_usergroups.map(&:id), user.id])
    domain_conditions            = sanitize_sql_for_conditions([" (hosts.domain_id in (?))",dms = (user.domains).map(&:id)])
    compute_resource_conditions  = sanitize_sql_for_conditions([" (hosts.compute_resource_id in (?))",(crs = user.compute_resources).map(&:id)])
    hostgroup_conditions         = sanitize_sql_for_conditions([" (hosts.hostgroup_id in (?))",(hgs = user.hostgroups).map(&:id)])

    fact_conditions = ""
    for user_fact in (ufs = user.user_facts)
      fact_conditions += sanitize_sql_for_conditions ["(hosts.id = fact_values.host_id and fact_values.fact_name_id = ? and fact_values.value #{user_fact.operator} ?)", user_fact.fact_name_id, user_fact.criteria]
      fact_conditions = user_fact.andor == "and" ? "(#{fact_conditions}) and " : "#{fact_conditions} or  "
    end
    if (match = fact_conditions.match(/^(.*).....$/))
      fact_conditions = "(#{match[1]})"
    end

    conditions = ""
    if user.filtering?
      conditions  = "#{owner_conditions}"                                                                                                                                 if     user.filter_on_owner
      (conditions = (user.domains_andor           == "and") ? "(#{conditions}) and #{domain_conditions} "           : "#{conditions} or #{domain_conditions} ")           unless dms.empty?
      (conditions = (user.compute_resources_andor == "and") ? "(#{conditions}) and #{compute_resource_conditions} " : "#{conditions} or #{compute_resource_conditions} ") unless crs.empty?
      (conditions = (user.hostgroups_andor        == "and") ? "(#{conditions}) and #{hostgroup_conditions} "        : "#{conditions} or #{hostgroup_conditions} ")        unless hgs.empty?
      (conditions = (user.facts_andor             == "and") ? "(#{conditions}) and #{fact_conditions} "             : "#{conditions} or #{fact_conditions} ")             unless ufs.empty?
      conditions.sub!(/\s*\(\)\s*/, "")
      conditions.sub!(/^(?:\(\))?\s?(?:and|or)\s*/, "")
      conditions.sub!(/\(\s*(?:or|and)\s*\(/, "((")
    end
    {:conditions => conditions}
  }

  scope :completer_scope, lambda { my_hosts }



  if SETTINGS[:unattended]
    # handles all orchestration of smart proxies.
    validates_uniqueness_of  :ip, :if => Proc.new {|host| host.require_ip_validation?}
    validates_uniqueness_of  :mac, :unless => Proc.new { |host| host.hypervisor? or host.compute? or !host.managed }
    validates_presence_of    :mac, :unless => Proc.new { |host| host.hypervisor? or host.compute? or !host.managed  }

    validates_format_of      :mac, :with => Net::Validations::MAC_REGEXP, :unless => Proc.new { |host| host.hypervisor_id or host.compute? or !host.managed }
    validates_format_of      :ip,        :with => Net::Validations::IP_REGEXP, :if => Proc.new { |host| host.require_ip_validation? }

  before_validation :set_hostgroup_defaults, :set_ip_address, :set_default_user, :normalize_addresses, :normalize_hostname
  after_validation :ensure_assoications



  def shortname
    domain.nil? ? name : name.chomp("." + domain.name)
  end


  # provide information about each node, mainly used for puppet external nodes
  # TODO: remove hard coded default parameters into some selectable values in the database.
  def info
    # Static parameters
    param = {}
    # maybe these should be moved to the common parameters, leaving them in for now
    param["puppetmaster"] = puppetmaster
    param["domainname"]   = domain.fullname unless domain.nil? or domain.fullname.nil?
    param["hostgroup"]    = hostgroup.to_label unless hostgroup.nil?
    if SETTINGS[:unattended]
      param["root_pw"]      = root_pass
      param["puppet_ca"]    = puppet_ca_server if puppetca?
    end
    param["comment"]      = comment unless comment.blank?
    param["foreman_env"]  = environment.to_s unless environment.nil? or environment.name.nil?
    if SETTINGS[:login] and owner
      param["owner_name"]  = owner.name
      param["owner_email"] = owner.is_a?(User) ? owner.mail : owner.users.map(&:mail)
    end

    if Setting[:ignore_puppet_facts_for_provisioning]
      param["ip"]  = ip
      param["mac"] = mac
    end
    param.update self.params

    info_hash = {}
    info_hash['classes'] = self.puppetclasses_names
    info_hash['parameters'] = param
    info_hash['environment'] = param["foreman_env"] if Setting["enc_environment"]

    info_hash
  end

  def params
    host_params.update(lookup_keys_params)
  end
  def clear_host_parameters_cache!
    @cached_host_params = nil
  end

  def host_inherited_params
    hp = {}
    # read common parameters
    CommonParameter.all.each {|p| hp.update Hash[p.name => p.value] }
    # read domain parameters
    domain.domain_parameters.each {|p| hp.update Hash[p.name => p.value] } unless domain.nil?
    # read OS parameters
    operatingsystem.os_parameters.each {|p| hp.update Hash[p.name => p.value] } unless operatingsystem.nil?
    # read group parameters only if a host belongs to a group
    hp.update hostgroup.parameters unless hostgroup.nil?
    hp
  end

  def host_params
    return cached_host_params unless cached_host_params.blank?
    hp = host_inherited_params
    # and now read host parameters, override if required
    host_parameters.each {|p| hp.update Hash[p.name => p.value] }
    @cached_host_params = hp
  end

  def lookup_keys_params
    return cached_lookup_keys_params unless cached_lookup_keys_params.blank?
    p = {}
    # lookup keys
    if Setting["Enable_Smart_Variables_in_ENC"]
      klasses  = puppetclasses.map(&:id)
      klasses += hostgroup.classes.map(&:id) if hostgroup
      LookupKey.all(:conditions => {:puppetclass_id =>klasses.flatten } ).each do |k|
        p[k.to_s] = k.value_for(self)
      end unless klasses.empty?
    end
    @cached_lookup_keys_params = p
  end

  def enforce_permissions operation
    if operation == "edit" and new_record?
      return true # We get called again with the operation being set to create
    end
    current = User.current
    if (operation == "edit") or operation == "destroy"
      if current.allowed_to?("#{operation}_hosts".to_sym)
        return true if Host.my_hosts(current).include? self
      end
    else # create
      if current.allowed_to?(:create_hosts)
        # We are unconstrained
        return true if current.domains.empty? and current.hostgroups.empty?
        # We are constrained and the constraint is matched
        return true if (!current.domains.empty?    and current.domains.include?(domain)) or
        (!current.hostgroups.empty? and current.hostgroups.include?(hostgroup))
      end
    end
    errors.add :base, "You do not have permission to #{operation} this host"
    false
  end

  def sp_valid?
    !sp_name.empty? and !sp_ip.empty? and !sp_mac.empty?
  end

  def jumpstart?
    operatingsystem.family == "Solaris" and architecture.name =~/Sparc/i rescue false
  end

  def set_hostgroup_defaults
    return unless hostgroup
    assign_hostgroup_attributes(%w{environment domain puppet_proxy puppet_ca_proxy})
    if SETTINGS[:unattended] and (new_record? or managed?)
      assign_hostgroup_attributes(%w{operatingsystem medium architecture ptable subnet})
      assign_hostgroup_attributes(Vm::PROPERTIES) if hostgroup.hypervisor? and not compute_resource_id
    end
  end

  def set_ip_address
    self.ip ||= subnet.unused_ip if subnet if SETTINGS[:unattended] and (new_record? or managed?)
  end


  def require_ip_validation?
    managed? and !compute? or (compute? and !compute_resource.provided_attributes.keys.include?(:ip))
  end


  def capabilities
    compute_resource_id ? compute_resource.capabilities : [:build]
  end

  def provider
    if compute_resource_id
      compute_resource.provider_friendly_name
    else
      "BareMetal"
    end
  end

  # no need to store anything in the db if the password is our default
  def root_pass
    read_attribute(:root_pass) || hostgroup.try(:root_pass) || Setting[:root_pass]
  end

  private

  def assign_hostgroup_attributes attrs = []
    attrs.each do |attr|
      eval("self.#{attr.to_s} ||= hostgroup.#{attr.to_s}")
    end
  end

  # checks if the host association is a valid association for this host
  def ensure_assoications
    status = true
    %w{ ptable medium architecture}.each do |e|
      value = self.send(e.to_sym)
      next if value.blank?
      unless os.send(e.pluralize.to_sym).include?(value)
        errors.add("#{e}_id".to_sym, "#{value} does not belong to #{os} operating system")
        status = false
      end
    end if SETTINGS[:unattended] and managed? and os

    puppetclasses.uniq.each do |e|
      unless environment.puppetclasses.include?(e)
        errors.add(:puppetclasses, "#{e} does not belong to the #{environment} environment")
        status = false
      end
    end if environment
    status
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

  def set_default_user
    self.owner ||= User.current
  end

  def set_certname
    self.certname = Foreman.uuid if read_attribute(:certname).blank? or new_record?
  end

end
