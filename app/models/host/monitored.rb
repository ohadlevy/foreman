module Host
  # monitored host is a host which only send its facts and reports to foreman
  class Monitored < Base
    include ReportCommon

    has_many :reports, :dependent => :destroy

    belongs_to :owner, :polymorphic => true

    validates_uniqueness_of  :name
    validates_presence_of    :name
    validate :is_name_downcased?



    scope :recent,      lambda { |*args| {:conditions => ["last_report > ?", (args.first || (Setting[:puppet_interval] + 5).minutes.ago)]} }
    scope :out_of_sync, lambda { |*args| {:conditions => ["last_report < ? and enabled != ?", (args.first || (Setting[:puppet_interval] + 5).minutes.ago), false]} }

    scope :with_error, { :conditions => "(puppet_status > 0) and
     ( ((puppet_status >> #{BIT_NUM*METRIC.index("failed")} & #{MAX}) != 0) or
      ((puppet_status >> #{BIT_NUM*METRIC.index("failed_restarts")} & #{MAX}) != 0) )"
    }

    scope :without_error, { :conditions =>
      "((puppet_status >> #{BIT_NUM*METRIC.index("failed")} & #{MAX}) = 0) and
       ((puppet_status >> #{BIT_NUM*METRIC.index("failed_restarts")} & #{MAX}) = 0)"
    }

    scope :with_changes, { :conditions => "(puppet_status > 0) and
      ( ((puppet_status >> #{BIT_NUM*METRIC.index("applied")} & #{MAX}) != 0) or
      ((puppet_status >> #{BIT_NUM*METRIC.index("restarted")} & #{MAX}) != 0) )"
    }

    scope :without_changes, { :conditions =>
      "((puppet_status >> #{BIT_NUM*METRIC.index("applied")} & #{MAX}) = 0) and
       ((puppet_status >> #{BIT_NUM*METRIC.index("restarted")} & #{MAX}) = 0)"
    }

    scope :with_pending_changes,    { :conditions =>
      "(puppet_status > 0) and ((puppet_status >> #{BIT_NUM*METRIC.index("pending")} & #{MAX}) != 0)" }
    scope :without_pending_changes, { :conditions =>
      "((puppet_status >> #{BIT_NUM*METRIC.index("pending")} & #{MAX}) = 0)" }

    scope :successful, lambda { without_changes.without_error.without_pending_changes}

    scope :alerts_disabled, {:conditions => ["enabled = ?", false] }

    scope :alerts_enabled, {:conditions => ["enabled = ?", true] }

    scope :run_distribution, lambda { |fromtime,totime|
      if fromtime.nil? or totime.nil?
        raise "invalid timerange"
      else
        { :joins      => "INNER JOIN reports ON reports.host_id = hosts.id",
          :conditions => ["reports.reported_at BETWEEN ? AND ?", fromtime, totime] }
      end
    }

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


    def error_count
      %w[failed failed_restarts].sum {|f| status f}
    end

    def no_report
      last_report.nil? or last_report < Time.now - (Setting[:puppet_interval] + 3).minutes and enabled?
    end

    def disabled?
      not enabled?
    end

    # alias to ensure same method that resolves the last report between the hosts and reports tables.
    def reported_at
      last_report
    end

    # puppet report status table column name
    def self.report_status
      "puppet_status"
    end

    def resources_chart(timerange = 1.day.ago)
      data = {}
      data[:applied], data[:failed], data[:restarted], data[:failed_restarts], data[:skipped] = [],[],[],[],[]
      reports.recent(timerange).each do |r|
        data[:applied]         << [r.reported_at.to_i*1000, r.applied ]
        data[:failed]          << [r.reported_at.to_i*1000, r.failed ]
        data[:restarted]       << [r.reported_at.to_i*1000, r.restarted ]
        data[:failed_restarts] << [r.reported_at.to_i*1000, r.failed_restarts ]
        data[:skipped]         << [r.reported_at.to_i*1000, r.skipped ]
      end
      data
    end

    def runtime_chart(timerange = 1.day.ago)
      data = {}
      data[:config], data[:runtime] = [], []
      reports.recent(timerange).each do |r|
        data[:config]  << [r.reported_at.to_i*1000, r.config_retrieval]
        data[:runtime] << [r.reported_at.to_i*1000, r.runtime]
      end
      data
    end

    def puppetrun!
      unless puppet_proxy.present?
        errors.add(:base, "no puppet proxy defined - cant continue")
        logger.warn "unable to execute puppet run, no puppet proxies defined"
        return false
      end
      ProxyAPI::Puppet.new({:url => puppet_proxy.url}).run fqdn
    rescue => e
      errors.add(:base, "failed to execute puppetrun: #{e}")
      false
    end

    # if certname does not exist, use hostname instead
    def certname
      read_attribute(:certname) || name
    end

    def clone
      new = super
      new.puppetclasses = puppetclasses
      # Clone any parameters as well
      host_parameters.each{|param| new.host_parameters << HostParameter.new(:name => param.name, :value => param.value, :nested => true)}
      # clear up the system specific attributes
      [:name, :mac, :ip, :uuid, :certname, :last_report, :sp_mac, :sp_ip, :sp_name, :puppet_status, ].each do |attr|
        new.send "#{attr}=", nil
      end
      new
    end

    protected

    def clearReports
      # Remove any reports that may be held against this host
      Report.delete_all("host_id = #{id}")
    end

    def is_name_downcased?
      return unless name.present?
      errors.add(:name, "must be downcase") unless name == name.downcase
    end

    # ensure that host name is fqdn
    # if the user inputted short name, the domain name will be appended
    # this is done to ensure compatibility with puppet storeconfigs
    def normalize_hostname
      # no hostname was given or a domain was selected, since this is before validation we need to ignore
      # it and let the validations to produce an error
      return if name.empty?

      # Remove whitespace
      self.name.gsub!(/\s/,'')

      if domain.nil? and name.match(/\./)
        # try to assign the domain automatically based on our existing domains from the host FQDN
        self.domain = Domain.all.select{|d| name.match(d.name)}.first rescue nil
      else
        # if our host is in short name, append the domain name
        if !new_record? and changed_attributes.keys.include? "domain_id"
          old_domain = Domain.find(changed_attributes["domain_id"])
          self.name.gsub(old_domain.to_s,"")
        end
        self.name += ".#{domain}" unless name =~ /.#{domain}$/i
      end
    end

  end
end