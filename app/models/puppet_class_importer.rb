class PuppetClassImporter

  def initialize args
    self.proxy = args[:proxy]
    @url       = args[:url]
  end

  def update_classes_for environment
    Rails.logger.debug "About to compare puppet classes changes for #{environment}"
    env = Environment.find_by_name environment

    new_classes_for(environment).each do |new_class|
      Rails.logger.debug "Adding #{new_class} to #{env}"
      klass = Puppetclass.find_or_create_by_name(new_class)
      klass.environments << env
      klass.valid? || Rails.logger.debug("failed to save puppet class #{klass.errors}")
      klass.save!
    end

    removed_classes_for(environment).each do |old_class|
      Rails.logger.debug "removing #{old_class} from the #{env} environment"
      klass = Puppetclass.find_by_name(old_class)
      env.puppetclasses.delete(klass)
      if klass.environments.empty?
        Rails.logger.debug "removing #{klass} from the database"
        klass.destroy
      end
    end
    true
  end

  def new_classes_for environment
    actual_classes(environment) - db_classes(environment)
  end

  def removed_classes_for environment
    db_classes(environment) - actual_classes(environment)
  end

  def proxy
    @proxy ||= ProxyAPI::Puppet.new(:url => url || find_a_usable_proxy.url)
  end

  def proxy= p
    return unless p
    return @proxy = p if p.is_a?(ProxyAPI::Puppet)
    raise "Invalid Proxy type, expected ProxyAPI::Puppet instance"
  end

  def db_environments
    Environment.all.map(&:name) - ignored_environments
  end

  def actual_environments
    proxy.environments.map(&:to_s) - ignored_environments
  end

  def new_environments
    actual_environments - db_environments
  end

  def db_classes environment
    return [] unless (env = Environment.find_by_name(environment))
    env.puppetclasses.select(:name).map(&:name)
  end

  def actual_classes environment
    proxy.classes(environment)
  end

  private
  attr_accessor :url

  def find_a_usable_proxy
    if (f = Feature.where(:name => "Puppet"))
      if !f.empty? and (proxies=f.first.smart_proxies)
        return proxies.first unless proxies.empty?
      end
    end
    nil
    raise "Can't find a valid Proxy with a Puppet feature" if url.blank?
  end

  def ignored_environments
    return [] unless File.exist? ignored_file
    YAML.load_file(ignored_file)[:ignored]
  rescue => e
    logger.warn "Failed to parse environment ignore file: #{e}"
    []
  end

  def ignored_file
    File.join(Rails.root.to_s, "config", "ignored_environments.yml")
  end

end
