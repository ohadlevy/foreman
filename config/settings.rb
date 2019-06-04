require_relative 'boot_settings'
require_relative '../app/services/foreman/version'

root = File.expand_path(File.dirname(__FILE__) + "/..")
settings_file = Rails.env.test? ? 'config/settings.yaml.test' : 'config/settings.yaml'

SETTINGS.merge! YAML.load(ERB.new(File.read("#{root}/#{settings_file}")).result) if File.exist?(settings_file)
SETTINGS[:version] = Foreman::Version.new

# Load settings from env variables
ENV_VARIABLE_SETTINGS_KEYS = {
  'FOREMAN_UNATTENDED' => [:boolean, :unattended],
  'FOREMAN_REQUIRE_SSL' => [:boolean, :require_ssl],
  'FOREMAN_SUPPORT_JSONP' => [:boolean, :support_jsonp],
  'FOREMAN_MARK_TRANSLATED' => [:boolean, :mark_translated],
  'FOREMAN_WEBPACK_DEV_SERVER' => [:boolean, :webpack_dev_server],
  'FOREMAN_WEBPACK_DEV_SERVER_HTTPS' => [:boolean, :webpack_dev_server_https],
  'FOREMAN_ASSETS_DEBUG' => [:boolean, :assets_debug],
  'FOREMAN_HSTS_ENABLED' => [:boolean, :hsts_enabled],
  'FOREMAN_RAILS' => [:boolean, :hsts_enabled],
  'FOREMAN_DOMAIN' => [:string, :domain],
  'FOREMAN_FQDN' => [:string, :fqdn],
  'FOREMAN_CORS_DOMAINS' => [:list, :cors_domains],
  'FOREMAN_LOGGING_LEVEL' => [:string, :logging, :level],
  'FOREMAN_LOGGING_PRODUCTION_TYPE' => [:string, :logging, :production, :type],
  'FOREMAN_LOGGING_PRODUCTION_LAYOUT' => [:string, :logging, :production, :layout],
  'FOREMAN_TELEMETRY_PREFIX' => [:string, :telemetry, :prefix],
  'FOREMAN_TELEMETRY_PROMETHEUS_ENABLED' => [:boolean, :telemetry, :prometheus, :enabled],
  'FOREMAN_TELEMETRY_STATSD_ENABLED' => [:boolean, :telemetry, :statsd, :enabled],
  'FOREMAN_TELEMETRY_STATSD_HOST' => [:string, :telemetry, :statsd, :host],
  'FOREMAN_TELEMETRY_STATSD_PROTOCOL' => [:string, :telemetry, :statsd, :protocol],
  'FOREMAN_TELEMETRY_LOGGER_ENABLED' => [:boolean, :telemetry, :logger, :enabled],
  'FOREMAN_TELEMETRY_LOGGER_LEVEL' => [:boolean, :telemetry, :logger, :level],
  'FOREMAN_DYNFLOW_POOL_SIZE' => [:integer, :dynflow, :pool_size]
}

LOGGERS_FROM_ENV_REGEX = /^FOREMAN_LOGGERS_([A-Z0-9_]+)_[A-Z]+$/
loggers_from_env = ENV.keys.grep(LOGGERS_FROM_ENV_REGEX).map { |key| key.gsub(LOGGERS_FROM_ENV_REGEX, '\1').downcase.gsub('__', '/').to_sym }.uniq

loggers_from_env.each do |logger|
  env_key = logger.to_s.upcase.gsub('/', '__')
  ENV_VARIABLE_SETTINGS_KEYS["FOREMAN_LOGGERS_#{env_key}_ENABLED"] = [:boolean, :loggers, logger, :enabled]
  ENV_VARIABLE_SETTINGS_KEYS["FOREMAN_LOGGERS_#{env_key}_LEVEL"] = [:string, :loggers, logger, :level]
end

ENV_VARIABLE_SETTINGS_KEYS.each do |env_key, definition|
  value = ENV[env_key]
  next unless value

  type = definition.shift

  value =
    case type
    when :integer
      value.to_i
    when :float
      value.to_f
    when :boolean
      !%w[0 false].include?(value.strip.downcase)
    when :list
      value.split(/[ ,]/)
    when :dict
      Hash[value.split(/[&,]/).map { |kv| kv.split('=') }]
    when :string
      value
    else
      raise "Unsupported type #{type} in definition for settings environment variable #{env_key}"
    end

  path = definition + [value]
  hsh = path.reverse.inject { |mem, key| {key => mem} }

  SETTINGS.merge!(hsh)
end

# Force setting to true until all code using it is removed
[:locations_enabled, :organizations_enabled].each do |setting|
  SETTINGS[setting] = true
end

# default to true if missing
[:unattended, :hsts_enabled].each do |setting|
  SETTINGS[setting] = SETTINGS.fetch(setting, true)
end

SETTINGS[:rails] = '%.1f' % SETTINGS[:rails] if SETTINGS[:rails].is_a?(Float) # unquoted YAML value

unless SETTINGS[:domain] && SETTINGS[:fqdn]
  require 'facter'
  SETTINGS[:domain] ||= Facter.value(:domain) || Facter.value(:hostname)
  SETTINGS[:fqdn] ||= Facter.value(:fqdn)
end

# Load plugin config, if any
Dir["#{root}/config/settings.plugins.d/*.yaml"].each do |f|
  SETTINGS.merge! YAML.load(ERB.new(File.read(f)).result)
end
