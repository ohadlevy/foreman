module Foreman::Model
  class EC2 < ComputeResource
    has_one :key_pair, :foreign_key => :compute_resource_id

    validates_presence_of :user, :password
    after_create :setup_key_pair
    after_destroy :destroy_key_pair

    def to_label
      "#{name} (#{region}-#{provider_friendly_name})"
    end

    def provided_attributes
      super.merge({ :mac => :mac, :ip => :public_ip_address, :name => :dns_name })
    end

    def self.model_name
      ComputeResource.model_name
    end

    def vm_instance_defaults
      {
        :flavor_id => "m1.small",
        :name      => "foreman-#{UUIDTools::UUID.random_create}",
        :key_pair  => self.key_pair,
      }
    end

    def find_vm_by_uuid uuid
      client.servers.get(uuid)
    rescue Fog::Compute::AWS::Error
      raise(ActiveRecord::RecordNotFound)
    end

    def create_vm args = { }
      args = vm_instance_defaults.merge(args.to_hash)
      vm   = super(args)
      client.tags.create :key => "Name", :value => args[:name], :resource_id => vm.identity, :resource_type => "instance" if vm && args[:name]
      vm
    end

    def security_groups
      client.security_groups.map(&:name)
    end

    def regions
      return [] if user.blank? or password.blank?
      @regions ||= client.describe_regions.body["regionInfo"].map { |r| r["regionName"] }
    end

    def zones
      @zones ||= client.describe_availability_zones.body["availabilityZoneInfo"].map { |r| r["zoneName"] if r["regionName"] == region }.compact
    end

    def flavors
      client.flavors
    end

    def test_connection
      super
      errors[:user].empty? and errors[:password] and regions
    rescue Fog::Compute::AWS::Error => e
      errors[:base] << e.message
    end

    def region= value
      self.url = value
    end

    def region
      @region ||= url.present? ? url : nil
    end

    private

    def client
      @client ||= ::Fog::Compute.new(:provider => "AWS", :aws_access_key_id => user, :aws_secret_access_key => password, :region => region)
    end

    # this method creates a new key pair for each new ec2 compute resource
    # it should create the key and upload it to AWS
    def setup_key_pair
      key = client.key_pairs.create :name => "foreman-#{id}#{UUIDTools::UUID.random_create}"
      KeyPair.create! :name => key.name, :compute_resource_id => self.id, :secret => key.private_key
    rescue => e
      logger.warn "failed to generate key pair"
      destroy_key_pair
      raise
    end

    def destroy_key_pair
      return unless key_pair
      logger.info "removing AWS key #{key_pair.name}"
      key = client.key_pairs.get(key_pair.name)
      key.destroy if key
      key_pair.destroy
      true
    rescue => e
      logger.warn "failed to delete key pair from AWS, you might need to cleanup manually : #{e}"
    end
  end
end
