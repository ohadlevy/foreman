class BMC < Interface

  PROVIDERS = %w(IPMI)
  validates :provider, :inclusion => { :in => PROVIDERS }

  [:username, :password, :provider].each do |method|
    define_method method do
      self.attrs ||= { }
      self.attrs[method]
    end

    define_method "#{method}=" do |value|
      self.attrs         ||= { }
      self.attrs[method] = value
    end
  end
end
