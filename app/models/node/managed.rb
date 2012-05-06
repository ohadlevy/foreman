class Node::Managed < Node::Monitored
  has_many :host_classes, :dependent => :destroy, :foreign_key => "host_id"
  has_many :puppetclasses, :through => :host_classes
  has_many :host_parameters, :dependent => :destroy, :foreign_key => :reference_id
  accepts_nested_attributes_for :host_parameters, :reject_if => lambda { |a| a[:value].blank? }, :allow_destroy => true

  attr_reader :cached_host_params, :cached_lookup_keys_params

  validates_uniqueness_of :name
  validates_presence_of :name, :environment_id
  validate :is_name_downcased?

   def self.model_name; Host.model_name; end

  scope :with_class, lambda { |klass|
    if klass.nil?
      raise "invalid class"
    else
      { :joins => :puppetclasses, :select => "hosts.name", :conditions => { :puppetclasses => { :name => klass } } }
    end
  }

  def is_name_downcased?
    return unless name.present?
    errors.add(:name, "must be downcase") unless name == name.downcase
  end

  #retuns fqdn of host puppetmaster
  def pm_fqdn
    puppetmaster == "puppet" ? "puppet.#{domain.name}" : "#{puppetmaster}"
  end

  # returns the list of puppetclasses a host is in.
  def puppetclasses_names
    all_puppetclasses.collect { |c| c.name }
  end

  def all_puppetclasses
    hostgroup.nil? ? puppetclasses : (hostgroup.classes + puppetclasses).uniq
  end

  def params
    host_params.update(lookup_keys_params)
  end

  def clear_host_parameters_cache!
    @cached_host_params = nil
  end

  def host_params
    return cached_host_params unless cached_host_params.blank?
    hp = { }
    # read common parameters
    CommonParameter.all.each { |p| hp.update Hash[p.name => p.value] }
    # read domain parameters
    domain.domain_parameters.each { |p| hp.update Hash[p.name => p.value] } unless domain.nil?
    # read OS parameters
    operatingsystem.os_parameters.each { |p| hp.update Hash[p.name => p.value] } unless operatingsystem.nil?
    # read group parameters only if a host belongs to a group
    hp.update hostgroup.parameters unless hostgroup.nil?
    # and now read host parameters, override if required
    host_parameters.each { |p| hp.update Hash[p.name => p.value] }
    @cached_host_params = hp
  end

  def lookup_keys_params
    return cached_lookup_keys_params unless cached_lookup_keys_params.blank?
    p = { }
    # lookup keys
    if Setting["Enable_Smart_Variables_in_ENC"]
      klasses = puppetclasses.map(&:id)
      klasses += hostgroup.classes.map(&:id) if hostgroup
      LookupKey.all(:conditions => { :puppetclass_id => klasses.flatten }).each do |k|
        p[k.to_s] = k.value_for(self)
      end unless klasses.empty?
    end
    @cached_lookup_keys_params = p
  end

  # this method accepts a puppets external node yaml output and generate a node in our setup
  # it is assumed that you already have the node (e.g. imported by one of the rack tasks)
  def importNode nodeinfo
    myklasses= []
    # puppet classes
    nodeinfo["classes"].each do |klass|
      if (pc = Puppetclass.find_by_name(klass))
        myklasses << pc
      else
        error = "Failed to import #{klass} for #{name}: doesn't exists in our database - ignoring"
        logger.warn error
        $stdout.puts error
      end
      self.puppetclasses = myklasses
    end

    # parameters are a bit more tricky, as some classifiers provide the facts as parameters as well
    # not sure what is puppet priority about it, but we ignore it if has a fact with the same name.
    # additionally, we don't import any non strings values, as puppet don't know what to do with those as well.

    myparams = self.info["parameters"]
    nodeinfo["parameters"].each_pair do |param, value|
      next if fact_names.exists? :name => param
      next unless value.is_a?(String)

      # we already have this parameter
      next if myparams.has_key?(param) and myparams[param] == value

      unless (hp = self.host_parameters.create(:name => param, :value => value))
        logger.warn "Failed to import #{param}/#{value} for #{name}: #{hp.errors.full_messages.join(", ")}"
        $stdout.puts $!
      end
    end

    self.save
  end

  # provide information about each node, mainly used for puppet external nodes
  # TODO: remove hard coded default parameters into some selectable values in the database.
  def info
    # Static parameters
    param                 = { }
    # maybe these should be moved to the common parameters, leaving them in for now
    param["puppetmaster"] = puppetmaster
    param["hostgroup"] = hostgroup.to_label unless hostgroup.nil?
    param["comment"] = comment unless comment.blank?
    param["foreman_env"] = environment.to_s unless environment.nil? or environment.name.nil?
    if SETTINGS[:login] and owner
      param["owner_name"]  = owner.name
      param["owner_email"] = owner.is_a?(User) ? owner.mail : owner.users.map(&:mail)
    end

    if Setting[:ignore_puppet_facts_for_provisioning]
      param["ip"]  = ip
      param["mac"] = mac
    end
    param.update self.params

    info_hash               = { }
    info_hash['classes']    = self.puppetclasses_names
    info_hash['parameters'] = param
    info_hash['environment'] = param["foreman_env"] if Setting["enc_environment"]

    info_hash
  end

  def my_hosts_conditions(user = User.current)
    return "" unless user.filtering?

    conditions = ""
    if user.hostgroups
      verb       = user.hostgroups_andor == "and" ? "and" : "or"
      conditions = sanitize_sql_for_conditions([" #{verb} (hosts.hostgroup_id in (?))", user.hostgroups.pluck(:id)])
    end

    "#{super} #{conditions}"

  end
end
