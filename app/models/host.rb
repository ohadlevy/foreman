module Host
  class Host

    def self.method_missing(method, *args, &block)
      super
    rescue NoMethodError
      Host::Base.send(method,*args, &block)
    end

  end
end
