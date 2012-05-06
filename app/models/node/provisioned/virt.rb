module Node::Provisioned
  class Virt < Node::Managed
    include Node::Provisioned::Common
    include Node::Provisioned::BuildCommon
    def self.model_name; Host.model_name; end

  end
end