object @hostgroup

attributes :name, :id, :subnet_id, :operatingsystem_id, :domain_id, :environment_id, :ancestry, :label, :parameters, :puppetclass_ids 

Vm::PROPERTIES.each do |property|
	attribute property.to_sym
end
