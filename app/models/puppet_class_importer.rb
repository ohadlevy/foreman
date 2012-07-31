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


    # Update the environments and puppetclasses based upon the user's selection
    # It does a best attempt and can fail to perform all operations due to the
    # user requesting impossible selections. Repeat the operation if errors are
    # shown, after fixing the request.
    # +changed+ : Hash with two keys: :new and :obsolete.
    #               changed[:/new|obsolete/] is and Array of Strings
    # Returns   : Array of Strings containing all record errors
  def obsolete_and_new changes = { }
    return if changes.empty?
    changes.values.map(&:keys).flatten.uniq.each do |env_name|
      if changes['new'] and changes['new'][env_name].try(:any?) # we got new classes
        add_classes_to_foreman(env_name, changes['new'][env_name])
      end
      if changes['obsolete'] and changes['obsolete'][env_name].try(:any?) # we need to remove classes
        remove_classes_from_foreman(env_name, changes['obsolete'][env_name])
      end
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

  def load_classes_from_json blob
    ActiveSupport::JSON.decode blob
  end

  def add_classes_to_foreman env_name, klasses
    classes     = find_existing_foreman_classes(klasses)
    new_classes = klasses - classes.map(&:name)
    classes     += create_new_puppet_classes_in_foreman(new_classes)

    env = find_or_create_env(env_name)
    env.puppetclasses << classes
  end

  def remove_classes_from_foreman env_name, klasses
    env = find_or_create_env(env_name)
    classes     = find_existing_foreman_classes(klasses)

    env.puppetclasses.delete classes

    # remove all old classes from hosts
    HostClass.joins(:host).where(:hosts => {:environment_id => env.id}, :puppetclass_id => classes).destroy_all

    # remove all klasses that have no environment now
    classes.not_in_any_environment.destroy_all

    if klasses.include? '_destroy_'
      # we can't guaranty that the env would be removed as it might have hosts attached to it.
      env.destroy
    end

  end

  def find_existing_foreman_classes klasses = []
    Puppetclass.where(:name => klasses)
  end

  def create_new_puppet_classes_in_foreman klasses = []
    Puppetclass.create klasses.map { |k| {:name => k} }
  end

  def find_or_create_env env
    Environment.where(:name => env).first || Environment.create!(:name => env)
  end

end
