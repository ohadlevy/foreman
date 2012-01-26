module Foreman::Model
  class EC2 < ComputeResource

    def class
      ComputeResource
    end

    def vm_instance_defaults
      {
        :flavor_id => "m1.small",
      }
    end

    protected

    def client
      @client ||= ::Fog::Compute.new(:provider => "AWS", :aws_access_key_id => user, :aws_secret_access_key => password, :host => url)
    end

  end
end
