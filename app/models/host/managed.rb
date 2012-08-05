module Host
  # Managed host is one which is used to classify information, such as an ENC
  class Managed < Monitored

    has_many :host_classes, :dependent => :destroy
    has_many :puppetclasses, :through => :host_classes
    belongs_to :hostgroup

    has_many :host_parameters, :dependent => :destroy, :foreign_key => :reference_id
    accepts_nested_attributes_for :host_parameters, :reject_if => lambda { |a| a[:value].blank? }, :allow_destroy => true


    validates_presence_of :environment_id
    validates_presence_of :puppet_proxy_id if SETTINGS[:unattended]

    scope :with_class, lambda { |klass|
      if klass.nil?
        raise "invalid class"
      else
        { :joins => :puppetclasses, :select => "hosts.name", :conditions => { :puppetclasses => { :name => klass } } }
      end
    }

    # returns fqdn of host puppetmaster
    # TODO: Revisit this
    def pm_fqdn
      puppetmaster == "puppet" ? "puppet.#{domain.name}" : "#{puppetmaster}"
    end

    # returns the list of puppetclasses a host is in.
    def puppetclasses_names
      all_puppetclasses.collect {|c| c.name}
    end

    def all_puppetclasses
      hostgroup.nil? ? puppetclasses : (hostgroup.classes + puppetclasses).uniq
    end

    # this method accepts a puppets external node yaml output and generate a node in our setup
    # it is assumed that you already have the node (e.g. imported by one of the rack tasks)
    def importNode nodeinfo

      # puppet classes
      # TODO: Fix to support param classes
      self.puppetclasses = Puppetclass.where(:name => nodeinfo["classes"])

      # not sure what is puppet priority about it, but we ignore it if has a fact with the same name.
      # additionally, we don't import any non strings values, as puppet don't know what to do with those as well.

      myparams = self.info["parameters"]
      nodeinfo["parameters"].each_pair do |param,value|
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

    # returns a rundeck output
    def rundeck
      rdecktags = puppetclasses_names.map{|k| "class=#{k}"}

      unless self.params["rundeckfacts"].empty?
        rdecktags += self.params["rundeckfacts"].split(",").map{|rdf| "#{rdf}=#{fact(rdf)[0].value}"}
      end

      { name => { "description" => comment, "hostname" => name, "nodename" => name,
                  "osArch" => arch.name, "osFamily" => os.family, "osName" => os.name,
                  "osVersion" => os.release, "tags" => rdecktags, "username" => self.params["rundeckuser"] || "root" }
      }
    rescue => e
      logger.warn "Failed to fetch rundeck info for #{to_s}: #{e}"
      {}
    end
  end
end