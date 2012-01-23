module Foreman::Model
  class Ovirt < ComputeResource

    def create_vm args = {}
      client.servers.create args
    end

    def class
      ComputeResource
    end

    protected

    def client
      @client ||= ::Fog::Compute.new(:provider => "ovirt", :ovirt_username => user, :ovirt_password => password, :ovirt_url => url)
    end

  end
end
