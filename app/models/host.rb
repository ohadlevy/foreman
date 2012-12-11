require 'facts_importer'

class Host < ActiveRecord::Base
  has_many :fact_values, :dependent => :destroy
  has_many :fact_names, :through => :fact_values

  class << self
    # ensures that the correct STI object is created when :type is passed.
    def new_with_cast(*attributes, &block)
      if (h = attributes.first).is_a?(Hash) && (type = h[:type]) && type.length > 0
        if (klass = type.constantize) != self
          raise "Invalid type #{type}" unless klass <= self
          return klass.new(*attributes, &block)
        end
      end

      new_without_cast(*attributes, &block)
    end

    alias_method_chain :new, :cast
  end

  def self.importHostAndFacts yaml
    facts = YAML::load yaml
    case facts
      when Puppet::Node::Facts
        certname = facts.values["certname"]
        name     = facts.values["fqdn"]
        values   = facts.values
      when Hash
        certname = facts["certname"]
        name     = facts["fqdn"]
        values   = facts
        return raise("invalid facts hash") unless name and values
      else
        return raise("Invalid Facts, much be a Puppet::Node::Facts or a Hash")
    end

    if name == certname or certname.nil?
      h = Host.find_by_name name
    else
      h = Host.find_by_certname certname
      h ||= Host.find_by_name name
    end
    h ||= Host.new :name => name

    h.save(:validate => false) if h.new_record?
    h.importFacts(name, values)
  end

  # import host facts, required when running without storeconfigs.
  # expect a Puppet::Node::Facts
  def importFacts name, facts

    # we are not importing facts for hosts in build state (e.g. waiting for a re-installation)
    raise "Host is pending for Build" if build
    time = facts[:_timestamp]
    time = time.to_time if time.is_a?(String)

    # we are not doing anything we already processed this fact (or a newer one)
    if time
      return true unless last_compile.nil? or (last_compile + 1.minute < time)
      self.last_compile = time
    end
    
    self.merge_facts(facts)
    save(:validate => false)

    populateFieldsFromFacts(facts)

    # we are saving here with no validations, as we want this process to be as fast
    # as possible, assuming we already have all the right settings in Foreman.
    # If we don't (e.g. we never install the server via Foreman, we populate the fields from facts
    # TODO: if it was installed by Foreman and there is a mismatch,
    # we should probably send out an alert.
    return self.save(:validate => false)

  rescue Exception => e
    logger.warn "Failed to save #{name}: #{e}"
  end

  def attributes_to_import_from_facts
    [:model]
  end

  def populateFieldsFromFacts facts = self.facts_hash
    importer = Facts::Importer.new facts

    set_non_empty_values importer, attributes_to_import_from_facts
    importer
  end

  # returns a hash of fact_names.name => [ fact_values ] for this host.
  # Note that 'fact_values' is actually a list of the value instances, not
  # just actual values.
  def get_facts_hash
    fact_values = self.fact_values.find(:all, :include => :fact_name)
    return fact_values.inject({}) do | hash, value |
      hash[value.fact_name.name] ||= []
      hash[value.fact_name.name] << value
      hash
    end
  end

  # This is *very* similar to the merge_parameters method
  def merge_facts(facts)
    db_facts = {}

    deletions = []
    self.fact_values.find(:all, :include => :fact_name).each do |value|
      deletions << value['id'] and next unless facts.include?(value['name'])
      # Now store them for later testing.
      db_facts[value['name']] ||= []
      db_facts[value['name']] << value
    end

    # Now get rid of any parameters whose value list is different.
    # This might be extra work in cases where an array has added or lost
    # a single value, but in the most common case (a single value has changed)
    # this makes sense.
    db_facts.each do |name, value_hashes|
      values = value_hashes.collect { |v| v['value'] }

      unless values == facts[name]
        value_hashes.each { |v| deletions << v['id'] }
      end
    end

    # Perform our deletions.
    FactValue.delete(deletions) unless deletions.empty?

    # Lastly, add any new parameters.
    facts.each do |name, value|
      next if db_facts.include?(name)
      values = value.is_a?(Array) ? value : [value]

      values.each do |v|
        #TODO make it one query IN instead of find_by
        fact_values.build(:value => v, :fact_name => FactName.find_or_create_by_name(name))
      end
    end
  end

end