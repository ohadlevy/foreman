module Foreman::Model
  class Ovirt < ComputeResource
    before_save :fetch_uuid

    def class
      ComputeResource
    end

    #FIXME
    def max_cpu_count
      8
    end

    def max_memory
      16*1024*1024*1024
    end

    def hardware_profiles
      client.templates.all(:search => 'name=hwp_*')
    end

    def hardware_profile(id)
      client.templates.get(id)
    end

    def clusters
      client.clusters
    end

    def networks(opts ={})
      if opts[:cluster_id]
        client.clusters.get(opts[:cluster_id]).networks
      else
        []
      end

    end

    def create_vm args = {}
      #ovirt doesn't accept '.' in vm name.
      args[:name] = args[:name].parameterize
      super args
    end

    protected

    def client
      @client ||= ::Fog::Compute.new(
        :provider => "ovirt",
        :ovirt_username => user,
        :ovirt_password => password,
        :ovirt_url => url,
        :ovirt_datacenter => uuid
      )
    end

    private

    def fetch_uuid
      filter = name.blank? ? "" : ("name=%s" % name)
      client = ::Fog::Compute.new(
        :provider => "ovirt",
        :ovirt_username => user,
        :ovirt_password => password,
        :ovirt_url => url)
        datacenters = client.datacenters(:search=>filter)

        if datacenters.empty?
          errors.add(:base, "Datacenter #{name} not found")
          false
        else
          self.uuid = datacenters.first.id
        end
    rescue => e
      errors.add(:base, e.message)
      false
    end

  end
end
