module Node
  autoload :Monitored, 'node/monitored'
  autoload :Managed, 'node/managed'
  if SETTINGS[:unattended]
    module Provisioned
      autoload :Common, 'node/provisioned/common'
      autoload :BuildCommon, 'node/provisioned/build_common'
      autoload :BareMetal, 'node/provisioned/bare_metal'
      autoload :Virt, 'node/provisioned/virt'
      autoload :Cloud, 'node/provisioned/cloud'
    end
  end
end
