module Host
  class Base < Puppet::Rails::Host
    include Authorization

    # audit the changes to this model
    audited :except => [:last_report, :puppet_status, :last_compile]
    has_associated_audits  belongs_to :model

    scope :with_fact, lambda { |fact,value|
      if fact.nil? or value.nil?
        raise "invalid fact"
      else
        { :joins  => "INNER JOIN fact_values fv_#{fact} ON fv_#{fact}.host_id = hosts.id
                     INNER JOIN fact_names fn_#{fact}  ON fn_#{fact}.id      = fv_#{fact}.fact_name_id",
          :select => "DISTINCT hosts.name, hosts.id", :conditions =>
          ["fv_#{fact}.value = ? and fn_#{fact}.name = ? and fv_#{fact}.fact_name_id = fn_#{fact}.id", value, fact] }
      end
    }

    alias_attribute :hostname, :name
    alias_attribute :fqdn, :name

    class << self
      def importHostAndFacts yaml
        facts = YAML::load yaml
        return false unless facts.is_a?(Puppet::Node::Facts)

        h = find_by_certname facts.name
        h ||= find_by_name facts.name
        h ||= new :name => facts.name

        h.save(:validate => false) if h.new_record?
        h.importFacts(facts)
      end

      # counts each association of a given host
      # e.g. how many hosts belongs to each os
      # returns sorted hash
      def count_distribution association
        output = {}
        count(:group => association).each do |k,v|
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
      def count_habtm association
        output = {}
        counter = count(:include => association.pluralize, :group => "#{association}_id")
        # returns {:id => count...}
        #Puppetclass.find(counter.keys.compact)...
        Hash[eval(association.camelize).send(:find, counter.keys.compact).map {|i| [i.to_label, counter[i.id]]}]
      end

    end

    def to_param
      name
    end

    def <=>(other)
      name <=> other.name
    end

    d

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

      populateFieldsFromFacts(facts.values)

      # we are saving here with no validations, as we want this process to be as fast
      # as possible, assuming we already have all the right settings in Foreman.
      # If we don't (e.g. we never install the server via Foreman, we populate the fields from facts
      # TODO: if it was installed by Foreman and there is a mismatch,
      # we should probably send out an alert.
      return self.save(:validate => false)

    rescue Exception => e
      logger.warn "Failed to save #{facts.name}: #{e}"
    end

    def populateFieldsFromFacts facts = self.facts_hash
      importer = Facts::Importer.new facts

      set_non_empty_values importer, facts_field_to_import
      normalize_addresses
      if Setting[:update_environment_from_facts]
        set_non_empty_values importer, [:environment]
      else
        self.environment ||= importer.environment unless importer.environment.blank?
      end

      self.save(:validate => false)
    end


    def classes_from_storeconfigs
      klasses = resources.all(:conditions => {:restype => "Class"}, :select => :title, :order => :title)
      klasses.map(&:title).delete(:main)
    end


    def can_be_build?
      false
    end

    def facts_hash
      hash = {}
      fact_values.all(:include => :fact_name).collect do |fact|
        hash[fact.fact_name.name] = fact.value
      end
      hash
    end

    def progress_report_id
      @progress_report_id ||= Foreman.uuid
    end

    def progress_report_id=(value)
      @progress_report_id = value
    end

    protected

    def clearFacts
      FactValue.delete_all("host_id = #{id}")
    end

    def facts_field_to_import
      [:domain, :architecture, :operatingsystem, :model, :certname, :mac, :ip]
    end

    # align common mac and ip address input
    def normalize_addresses
      # a helper for variable scoping
      helper = []
      [self.mac,self.sp_mac].each do |m|
        unless m.empty?
          m.downcase!
          if m=~/[a-f0-9]{12}/
            m = m.gsub(/(..)/){|mh| mh + ":"}[/.{17}/]
          elsif mac=~/([a-f0-9]{1,2}:){5}[a-f0-9]{1,2}/
            m = m.split(":").map{|nibble| "%02x" % ("0x" + nibble)}.join(":")
          end
        end
        helper << m
      end
      self.mac, self.sp_mac = helper

      helper = []
      [self.ip,self.sp_ip].each do |i|
        unless i.empty?
          i = i.split(".").map{|nibble| nibble.to_i}.join(".") if i=~/(\d{1,3}\.){3}\d{1,3}/
        end
        helper << i
      end
      self.ip, self.sp_ip = helper
    end

    def set_non_empty_values importer, methods
      methods.each do |attr|
        value = importer.send(attr)
        self.send("#{attr}=", value) unless value.blank?
      end
    end
  end
end