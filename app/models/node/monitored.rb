class Node::Monitored < Host
  include ReportCommon
  include HostCommon
  belongs_to :hostgroup
  has_many :reports, :dependent => :destroy, :foreign_key => "host_id"

  # some shortcuts
  alias_attribute :os, :operatingsystem
  alias_attribute :arch, :architecture
  alias_attribute :hostname, :name
  alias_attribute :fqdn, :name

  def self.model_name; Host.model_name; end
  scope :recent, lambda { |*args| { :conditions => ["last_report > ?", (args.first || (Setting[:puppet_interval] + 5).minutes.ago)] } }
  scope :out_of_sync, lambda { |*args| { :conditions => ["last_report < ? and enabled != ?", (args.first || (Setting[:puppet_interval] + 5).minutes.ago), false] } }

  scope :with_fact, lambda { |fact, value|
    if fact.nil? or value.nil?
      raise "invalid fact"
    else
      { :joins  => "INNER JOIN fact_values fv_#{fact} ON fv_#{fact}.host_id = hosts.id
                   INNER JOIN fact_names fn_#{fact}  ON fn_#{fact}.id      = fv_#{fact}.fact_name_id",
        :select => "DISTINCT hosts.name, hosts.id", :conditions =>
        ["fv_#{fact}.value = ? and fn_#{fact}.name = ? and fv_#{fact}.fact_name_id = fn_#{fact}.id", value, fact] }
    end
  }

  # audit the changes to this model
  acts_as_audited :except => [:last_report, :puppet_status, :last_compile]
  has_associated_audits

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

  scope :with_pending_changes, { :conditions =>
                                   "(puppet_status > 0) and ((puppet_status >> #{BIT_NUM*METRIC.index("pending")} & #{MAX}) != 0)" }
  scope :without_pending_changes, { :conditions =>
                                      "((puppet_status >> #{BIT_NUM*METRIC.index("pending")} & #{MAX}) = 0)" }

  scope :successful, lambda { without_changes.without_error.without_pending_changes }

  scope :alerts_disabled, { :conditions => ["enabled = ?", false] }

  scope :run_distribution, lambda { |fromtime, totime|
    if fromtime.nil? or totime.nil?
      raise "invalid timerange"
    else
      { :joins      => "INNER JOIN reports ON reports.host_id = hosts.id",
        :conditions => ["reports.reported_at BETWEEN ? AND ?", fromtime, totime] }
    end
  }

  def clearReports
    # Remove any reports that may be held against this host
    Report.delete_all("host_id = #{id}")
  end


  # reports methods

  def error_count
    %w[failed failed_restarts].sum { |f| status f }
  end

  def no_report
    last_report.nil? or last_report < Time.now - (Setting[:puppet_interval] + 3).minutes and enabled?
  end

  def disabled?
    not enabled?
  end


  def resources_chart(timerange = 1.day.ago)
    data                                                                                    = { }
    data[:applied], data[:failed], data[:restarted], data[:failed_restarts], data[:skipped] = [], [], [], [], []
    reports.recent(timerange).each do |r|
      data[:applied] << [r.reported_at.to_i*1000, r.applied]
      data[:failed] << [r.reported_at.to_i*1000, r.failed]
      data[:restarted] << [r.reported_at.to_i*1000, r.restarted]
      data[:failed_restarts] << [r.reported_at.to_i*1000, r.failed_restarts]
      data[:skipped] << [r.reported_at.to_i*1000, r.skipped]
    end
    data
  end

  def runtime_chart(timerange = 1.day.ago)
    data                          = { }
    data[:config], data[:runtime] = [], []
    reports.recent(timerange).each do |r|
      data[:config] << [r.reported_at.to_i*1000, r.config_retrieval]
      data[:runtime] << [r.reported_at.to_i*1000, r.runtime]
    end
    data
  end

  def classes_from_storeconfigs
    klasses = resources.all(:conditions => { :restype => "Class" }, :select => :title, :order => :title)
    klasses.map!(&:title).delete(:main)
    klasses
  end

  # returns a rundeck output
  def rundeck
    rdecktags = puppetclasses_names.map { |k| "class=#{k}" }
    unless self.params["rundeckfacts"].empty?
      rdecktags += self.params["rundeckfacts"].split(",").map { |rdf| "#{rdf}=#{fact(rdf)[0].value}" }
    end
    { name => { "description" => comment, "hostname" => name, "nodename" => name,
                "osArch"      => arch.name, "osFamily" => os.family, "osName" => os.name,
                "osVersion"   => os.release, "tags" => rdecktags, "username" => self.params["rundeckuser"] || "root" }
    }
  rescue => e
    logger.warn "Failed to fetch rundeck info for #{to_s}: #{e}"
    { }
  end

  def puppetrun!
    unless puppet_proxy.present?
      errors.add(:base, "no puppet proxy defined - cant continue")
      logger.warn "unable to execute puppet run, no puppet proxies defined"
      return false
    end
    ProxyAPI::Puppet.new({ :url => puppet_proxy.url }).run fqdn
  rescue => e
    errors.add(:base, "failed to execute puppetrun: #{e}")
    false
  end

  # alias to ensure same method that resolves the last report between the hosts and reports tables.
  def reported_at
    last_report
  end

  # puppet report status table column name
  def self.report_status
    "puppet_status"
  end

  def populateFieldsFromFacts facts = self.facts_hash
    importer = Facts::Importer.new facts

    set_non_empty_values importer, [:domain, :architecture, :operatingsystem, :model]
    set_non_empty_values importer, [:mac, :ip] unless Setting[:ignore_puppet_facts_for_provisioning]

    if Setting[:update_environment_from_facts]
      set_non_empty_values importer, [:environment]
    else
      self.environment ||= importer.environment unless importer.environment.blank?
    end

    self.save(:validate => false)
  end
end
