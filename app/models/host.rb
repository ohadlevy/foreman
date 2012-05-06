require 'facts_importer'

class Host < Puppet::Rails::Host
  include Authorization
  include Node::Search
  belongs_to :model
  belongs_to :owner, :polymorphic => true

  before_validation :set_default_user

  scope :my_hosts, lambda { { :conditions => my_hosts_conditions.conditions.sub(/\s*\(\)\s*/, "").conditions.sub(/^(?:\(\))?\s?(?:and|or)\s*/, "").conditions.sub(/\(\s*(?:or|and)\s*\(/, "((") } }
  # ensures search also limit results based on permissions
  scope :completer_scope, lambda { my_hosts }

  def to_param
    name
  end

  # method to return the correct owner list for host edit owner select dropbox
  def is_owned_by
    owner.id_and_type if owner
  end

  # virtual attributes which sets the owner based on the user selection
  # supports a simple user, or a usergroup
  # selection parameter is expected to be an ActiveRecord id_and_type method (see Foreman's AR extentions).
  def is_owned_by=(selection)
    oid = User.find(selection.to_i) if selection =~ (/-Users$/)
    oid = Usergroup.find(selection.to_i) if selection =~ (/-Usergroups$/)
    self.owner = oid
  end

  def clearFacts
    FactValue.delete_all("host_id = #{id}")
  end

  def self.importHostAndFacts yaml
    facts = YAML::load yaml
    return false unless facts.is_a?(Puppet::Node::Facts)

    h=find_or_create_by_name(facts.name)
    h.save(:validate => false) if h.new_record?
    h.importFacts(facts)
  end

  def set_default_user
    self.owner ||= User.current
  end

  # counts each association of a given host
  # e.g. how many hosts belongs to each os
  # returns sorted hash
  def self.count_distribution assocication
    output = { }
    count(:group => assocication).each do |k, v|
      begin
        output[k.to_label] = v unless v == 0
      rescue
        logger.info "skipped #{k} as it has has no label"
      end
    end
    output
  end

  # counts each association of a given host for HABTM relationships
  # TODO: Merge these two into one method
  # e.g. how many hosts belongs to each os
  # returns sorted hash
  def self.count_habtm association
    output = { }
    Host.count(:include => association.pluralize, :group => "#{association}_id").to_a.each do |a|
      #Ugly Ugly Ugly - I guess I'm missing something basic here
      if a[0]
        label         = eval(association.camelize).send("find", a[0].to_i).to_label
        output[label] = a[1]
      end
    end
    output
  end

  def facts_hash
    hash = { }
    fact_values.all(:include => :fact_name).collect do |fact|
      hash[fact.fact_name.name] = fact.value
    end
    hash
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
        return true if (!current.domains.empty? and current.domains.include?(domain)) or
          (!current.hostgroups.empty? and current.hostgroups.include?(hostgroup))
      end
    end
    errors.add :base, "You do not have permission to #{operation} this host"
    false
  end

  def set_non_empty_values importer, methods
    methods.each do |attr|
      value = importer.send(attr)
      self.send("#{attr}=", value) unless value.blank?
    end
  end

  def my_hosts_conditions(user = User.current)
    #TODO: rewrite this not using string based conditions
    return "" unless user.filtering?
    conditions = ""

    if user.filter_on_owner
      conditions = sanitize_sql_for_conditions(["((hosts.owner_id in (?) AND hosts.owner_type = 'Usergroup') OR (hosts.owner_id = ? AND hosts.owner_type = 'User'))", user.my_usergroups.map(&:id), user.id])
    end

    if user.user_facts
      fact_conditions = ""
      verb            = user.facts_andor == "and" ? "and" : "or"
      user.user_facts.each do |user_fact|
        fact_conditions += sanitize_sql_for_conditions ["(hosts.id = fact_values.host_id and fact_values.fact_name_id = ? and fact_values.value #{user_fact.operator} ?)", user_fact.fact_name_id, user_fact.criteria]
        fact_conditions = "(#{fact_conditions}) #{verb} "
      end
      fact_conditions = "(#{match[1]})" if (match = fact_conditions.match(/^(.*).....$/))
      conditions += "#{verb} #{fact_conditions}"
    end

    conditions
  end

  # import host facts, required when running without storeconfigs.
  # expect a Puppet::Node::Facts
  def importFacts facts
    raise "invalid Fact" unless facts.is_a?(Puppet::Node::Facts)

    # we are not importing facts for hosts in build state (e.g. waiting for a re-installation)
    raise "Host is pending for Build" if build
    time = facts.values[:_timestamp]
    time = time.to_time if time.is_a?(String)

    # we are not doing anything we already processed this fact (or a newer one)
    return true unless last_compile.nil? or (last_compile + 1.minute < time)

    self.last_compile = time
    # save all other facts - pre 0.25 it was called setfacts
    respond_to?("merge_facts") ? self.merge_facts(facts.values) : self.setfacts(facts.values)
    save(:validate => false)

    # we want to import other information only if this host was never installed via Foreman
    populateFieldsFromFacts(facts.values) if installed_at.nil?

    # we are saving here with no validations, as we want this process to be as fast
    # as possible, assuming we already have all the right settings in Foreman.
    # If we don't (e.g. we never install the server via Foreman, we populate the fields from facts
    # TODO: if it was installed by Foreman and there is a mismatch,
    # we should probably send out an alert.
    return self.save(:validate => false)

  rescue Exception => e
    logger.warn "Failed to save #{facts.name}: #{e}"
  end
  def self.descends_from_active_record?
    @dar ||= to_s == "Host"
  end
end
