module Host

  def self.method_missing(method, *args, &block)
    super
  rescue NoMethodError
    if [:create, :new, :create!].include?(method)
      args[0][:type] ||= 'Host::Managed'
    end
    Host::Managed.send(method,*args, &block)
  end

end
