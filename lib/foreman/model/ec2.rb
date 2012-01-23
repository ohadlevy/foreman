module Foreman::Model
  class EC2 < ComputeResource

    def create_vm args = {}
      client.servers.create args
    end

    def class
      ComputeResource
    end

    protected

    def client
      @client ||= ::Fog::Compute.new(:provider => "AWS", :aws_access_key_id => user, :aws_secret_access_key => password, :host => url)
    end

  end
end
