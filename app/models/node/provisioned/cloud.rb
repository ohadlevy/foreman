module Node::Provisioned
  class Cloud < Node::Managed
    include Node::Provisioned::Common
    def self.model_name; Host.model_name; end

  end
end