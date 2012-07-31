class Environment < ActiveRecord::Base
  has_and_belongs_to_many :puppetclasses
  has_many :hosts
  validates_presence_of :name
  validates_uniqueness_of :name
  validates_format_of :name, :with => /^[\w\d]+$/, :message => "is alphanumeric and cannot contain spaces"
  has_many :config_templates, :through => :template_combinations, :dependent => :destroy
  has_many :template_combinations

  before_destroy EnsureNotUsedBy.new(:hosts)
  default_scope :order => 'LOWER(environments.name)'

  scoped_search :on => :name, :complete_value => :true

  def to_param
    name
  end

  class << self

    #TODO: this needs to be removed, as PuppetDOC generation no longer works
    # if the manifests are not on the foreman host

    # returns an hash of all puppet environments and their relative paths
    def puppetEnvs proxy = nil
      #TODO: think of a better way to model multiple puppet proxies
      url = (proxy || SmartProxy.puppet_proxies.first).try(:url)
      raise "Can't find a valid Foreman Proxy with a Puppet feature" if url.blank?
      proxy = ProxyAPI::Puppet.new :url => url
      HashWithIndifferentAccess[proxy.environments.map { |e| [e, proxy.classes(e)] }]
    end

  end

  def as_json(options={ })
    options ||= { }
    super({ :only => [:name, :id] }.merge(options))
  end

end
