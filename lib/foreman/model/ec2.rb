module Foreman::Model
  class EC2 < ComputeResource

    validates_presence_of :user, :password

    def self.model_name
      ComputeResource.model_name
    end

    def vm_instance_defaults
      {
        :flavor_id => "m1.small",
        :use_image => true,
      }
    end

    def find_vm_by_uuid uuid
      client.servers.get(uuid)
    rescue Fog::Compute::AWS::Error
      raise(ActiveRecord::RecordNotFound)
    end

    def create_vm args = {}
      super(args)
    end

    def key_pairs
      client.key_pairs.map(&:name)
    end

    def security_groups
      client.security_groups.map(&:name)
    end

    def regions
      return [] if user.blank? or password.blank?
      @regions ||= client.describe_regions.body["regionInfo"].map{|r| r["regionName"]}
    end

    def zones
      @zones ||= client.describe_availability_zones.body["availabilityZoneInfo"].map{|r| r["zoneName"] if r["regionName"] == region}.compact
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

  end
end
