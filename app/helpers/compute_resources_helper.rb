module ComputeResourcesHelper
  def vm_state s
    s ? "Off" : " On"
  end

  def vm_power_class s
    "class='label #{s ? "success" : ""}'"
  end

  def vm_power_action vm
    opts = hash_for_power_compute_resource_vm_path(:compute_resource_id => @compute_resource, :id => vm.identity)
    html = vm.ready? ? { :confirm => 'Are you sure?', :class => "label important" } : { :class => "label notice" }

    display_link_if_authorized "Power#{state(vm.ready?)}", opts, html.merge(:method => :put)
  end

  def memory_options max_memory
    max = max_memory / 1024 / 1024
    mem_opts = (1..max).to_a.map {|n| [number_to_human_size(2**n*1024*128), n]}
    options_for_select mem_opts
  end
end
