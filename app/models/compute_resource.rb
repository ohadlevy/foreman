class ComputeResource < ActiveRecord::Base
  PROVIDERS = %w[ Libvirt Ovirt EC2 ]

  include Authorization
  validates_format_of :name, :with => /\A(\S+)\Z/, :message => "can't be blank or contain white spaces."
  validates_uniqueness_of :name
  validates_presence_of :provider, :in => PROVIDERS
  validates_presence_of :url
  scoped_search :on => :name, :complete_value => :true
  before_save :sanitize_url

  def self.new_provider args
    provider = args[:provider]

    case provider.downcase
    when "ovirt"
      Foreman::Model::Ovirt.new(args)
    when "libvirt"
      Foreman::Model::Libvirt.new(args)
    when "EC2"
      Foreman::Model::EC2.new(args)
    else
      ComputeResource.new(args)
    end
  end

  def to_param
    "#{id}-#{name.parameterize}"
  end

   def new_vm
      client.servers.new vm_instance_defaults
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
  end

  def destroy_vm uuid
    find_vm_by_uuid(uuid).destroy
  end

  # to STI avoid namespace issues, we append Foreman::Model in our database type column
  def provider
    read_attribute(:type).to_s.gsub("Foreman::Model::","")
  end

  def provider=(value)
    self.type = "Foreman::Model::#{value}"
  end

  protected

  def client
  end

  def sanitize_url
    self.url.chomp!("/") unless url.empty?
  end

end
