class HWProfile < ActiveRecord::Base
  belongs_to :compute_resource

  serialize :vm_attributes, Hash

end
