class PuppetClassImporter

  def initialize args = { }
    self.proxy = args[:proxy]
    @url       = args[:url]
  end

  # return changes hash, currently exists to keep compatibility with importer html
  def changes
    changes = { 'new' => { }, 'obsolete' => { } }

    actual_environments.each do |env|
      new = new_classes_for(env)
      old = removed_classes_for(env)
      changes['new'][env] = new if new.any?
      changes['obsolete'][env] = old if old.any?
    end

    old_environments.each do |env|
      changes['obsolete'][env] ||= []
    end
    changes
  end


  def obsolete_and_new changes = { }
    changes['new'].each do |environment, attrs|
      env         = find_or_create_env(environment)
      classes     = Puppetclass.where(:name => attrs['puppetclasses'])
      new_classes = (attrs['puppetclasses'] - classes.map(&:to_s)).map { |c| { :name => c } }
      classes     += Puppetclass.create(new_classes)
      env.puppetclasses << classes
    end
    changes['obsolete'].each do |environment, attrs|
      env     = find_or_create_env(environment)
      classes = Puppetclass.where(:name => attrs['puppetclasses'])

      env.destroy if attrs['puppetclasses'].include? "_destroy_"


    end
  end

  # batched based update
  def update_classes_for environment
    logger.debug "About to compare puppet classes changes for #{environment}"
    env = Environment.find_by_name environment
    raise "Environment #{environments} does not exits" if env.nil?

    new_classes_for(environment).each do |new_class|
      logger.debug "Adding #{new_class} to #{env}"
      klass = Puppetclass.find_or_create_by_name(new_class)
      klass.environments << env
      klass.valid? || logger.debug("failed to save puppet class #{klass.errors}")
      klass.save!
    end

    removed_classes_for(environment).each do |old_class|
      logger.debug "removing #{old_class} from the #{env} environment"
      klass = Puppetclass.find_by_name(old_class)
      env.puppetclasses.delete(klass)
      if klass.environments.empty?
        logger.debug "removing #{klass} from the database"
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

  def db_environments
    @foreman_envs ||= (Environment.all.map(&:name) - ignored_environments)
  end

  def actual_environments
    @proxy_envs ||= (proxy.environments.map(&:to_s) - ignored_environments)
  end

  def new_environments
    actual_environments - db_environments
  end

  def old_environments
    db_environments - actual_environments
  end

  def db_classes environment
    return @foreman_classes if @foreman_classes
    return [] unless (env = Environment.find_by_name(environment))
    @foreman_classes ||= env.puppetclasses.select(:name).map(&:name)
  end

  def actual_classes environment
    @proxy_classes ||= proxy.classes(environment).map(&:to_s)
  end

  private
  attr_accessor :url

  def ignored_environments
    return [] unless File.exist? ignored_file
    result = YAML.load_file(ignored_file)[:ignored]
    return result if result.is_a?(Array)
    []
  rescue => e
    logger.warn "Failed to parse environment ignore file: #{e}"
    []
  end

  def ignored_file
    File.join(Rails.root.to_s, "config", "ignored_environments.yml")
  end

  def logger
    @logger ||= Rails.logger
  end

  def proxy
    return @proxy unless @proxy.nil?
    url ||= SmartProxy.puppet_proxies.first.try(:url)
    raise "Can't find a valid Proxy with a Puppet feature" if url.blank?
    @proxy ||= ProxyAPI::Puppet.new(:url => url)
  end

  def proxy= p
    return unless p
    return @proxy = p if p.is_a?(ProxyAPI::Puppet)
    raise "Invalid Proxy type, expected ProxyAPI::Puppet instance"
  end

  def find_or_create_env name
    Environment.where(:name => name).first || Environment.create!(:name => name)
  end

end
