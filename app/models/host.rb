module Host

  def self.method_missing(method, *args, &block)
    super
  rescue NoMethodError
    if [:create, :new, :create!].includes?(method)
      args[:type] ||= 'Host::Managed'
    end
    Host::Base.send(method,*args, &block)
  end

end
