class ComputeResource < ActiveRecord::Base
  PROVIDERS = %w[ Libvirt Ovirt EC2 ]

  # to STI avoid namespace issues when loading the class, we append Foreman::Model in our database type column
  STI_PREFIX= "Foreman::Model"

  include Authorization
  validates_format_of :name, :with => /\A(\S+)\Z/, :message => "can't be blank or contain white spaces."
  validates_uniqueness_of :name
  validates_presence_of :provider, :in => PROVIDERS
  validates_presence_of :url
  scoped_search :on => :name, :complete_value => :true
  before_save :sanitize_url
  has_many :hosts

  # allows to create a specific compute class based on the provider.
  def self.new_provider args
    raise "must provider a provider" unless provider = args[:provider]
    PROVIDERS.each do |p|
      return eval("#{STI_PREFIX}::#{p}").new(args) if p.downcase == provider.downcase
    end
    raise "unknown Provider"
  end

  def to_param
    "#{id}-#{name.parameterize}"
  end

  # retuns a new fog server instance
  def new_vm attr={}
    client.servers.new vm_instance_defaults.merge(attr)
  end

  # return a list of virtual machines
  def vms
    client.servers
  end

  def find_vm_by_uuid uuid
    client.servers.get(uuid) || raise(ActiveRecord::RecordNotFound)
  end

  def start_vm uuid
    find_vm_by_uuid(uuid).start
  end

  def stop_vm uuid
    find_vm_by_uuid(uuid).stop
  end

  def create_vm args = {}
    client.servers.create vm_instance_defaults.merge(args.to_hash)
  rescue Fog::Errors::Error => e
    errors.add(:base, e.to_s)
    false
  end

  def destroy_vm uuid
    find_vm_by_uuid(uuid).destroy
  end

  def provider
    read_attribute(:type).to_s.gsub("#{STI_PREFIX}::","")
  end

  def provider=(value)
    if PROVIDERS.include? value
      self.type = "#{STI_PREFIX}::#{value}"
    else
      raise "Invalid Provider"
    end
  end

  def vm_instance_defaults
    {
      'name' => "foreman_#{Time.now.to_i}",
    }
  end

  def hardware_profiles
  end

  def hardware_profile(id)
  end

  protected

  def client
    raise "Not implemented"
  end

  def sanitize_url
    self.url.chomp!("/") unless url.empty?
  end

end
