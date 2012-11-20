class Interface < ActiveRecord::Base
  include Orchestration
  include Orchestration::DHCP
  include Orchestration::DNS

  attr_accessible :role,
                  :host_id, :host,
                  :subnet_id, :subnet,
                  :domain_id, :domain,
                  :mac, :ip, :name,
                  :_destroy # used for nested_attributes

  TYPES = %w[ NIC Bootable BMC ]

  validates_uniqueness_of :mac
  validates_format_of :mac, :with => Net::Validations::MAC_REGEXP

  validates_uniqueness_of :ip
  validates_format_of :ip, :with => Net::Validations::IP_REGEXP

  validate :uniq_ip_and_mac_with_hosts

  validates_inclusion_of :type, :in => TYPES
  validates_presence_of :host

  belongs_to :host, :inverse_of => :interfaces
  belongs_to :subnet
  belongs_to :domain

  delegate :vlanid, :network, :to => :subnet
  delegate :require_ip_validation?, :overwrite?, :capabilities, :managed?, :to => :host

  scope :bootable, where(:type => "Bootable")
  scope :bmc, where(:type => "BMC")

  before_validation :normalize_addresses

  # keep extra attributes needed for sub classes.
  serialize :attrs, Hash

  class << self
    # ensures that the correct STI object is created when :type is passed.
    def new_with_cast(*attributes, &block)
      if (h = attributes.first).is_a?(Hash) && (type = h[:type] || h[:role]) && type.length > 0
        if (klass = type.constantize) != self
          raise "Invalid type #{type}" unless klass <= self
          return klass.new(*attributes, &block)
        end
      end

      new_without_cast(*attributes, &block)
    end

    alias_method_chain :new, :cast
  end

  # Interface normally are not executed by them self, so we should use the host queue
  # if we later on update a single interface (e.g. via rest) we should update this code accordingly
  delegate :progress_report_id, :to => :host

  def queue_with_host
    host.queue.nil? ? queue_without_host : host.queue
  end
  alias_method_chain :queue, :host

  # returns a DHCP reservation object
  def dhcp_record
    return unless dhcp? or @dhcp_record
    @dhcp_record ||= Net::DHCP::Record.new(dhcp_attrs)
  end

  def role
    read_attribute(:type)
  end

  def role=(value)
    raise "invalid type" unless TYPES.include? value
    self.type = value
  end

  protected

  # returns a hash of dhcp record attributes
  def dhcp_attrs
    raise "DHCP not supported for this NIC" unless dhcp?
    {
      :hostname => name,
      :ip       => ip,
      :mac      => mac,
      :proxy    => subnet.dhcp_proxy,
      :network  => network
    }
  end

  private

  def normalize_addresses
    self.mac = Net::Validations.normalize_mac(mac)
    self.ip  = Net::Validations.normalize_ip(ip)
  end

  # make sure we don't have a conflicting interface with an host record
  def uniq_ip_and_mac_with_hosts
    failed = false
    [:mac, :ip].each do |attr|
      value = self.send(attr)
      unless value.blank?
        unless Host.where(attr => value).limit(1).pluck(attr).empty?
          errors.add attr, "already in use"
          failed = true
        end
      end
    end
    !failed
  end

end
