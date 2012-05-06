require 'fog'

class Foreman::Provision::SSH
  attr_reader :template, :uuid, :results

  def initialize address, username = "root", options = { }
    @template = options.delete(:template) || raise("must provide a template")
    @uuid     = options.delete(:uuid) || "#{address}-#{username}"
    options   = defaults.merge(options)
    @ssh      = ::Fog::SSH.new(address, username, options)
    @scp      = ::Fog::SCP.new(address, username, options)
  end

  def deploy!
    logger.debug "about to upload #{template} to remote system at #{remote_script}"
    scp.upload(template, remote_script)
    logger.debug "about to execute #{command}"
    @results = ssh.run(command)
    logger.info stdout
    logger.debug stderr
    success?
  end

  def success?
    return true if results.empty?
    results.map(&:status).compact == [0]
  end

  def stdout
    results.each do |r|
      r.display_stdout
    end
  end

  def stderr
    results.each do |r|
      r.display_stderr
    end
  end

  private
  attr_reader :ssh, :scp, :logger

  def remote_script
    File.join("/", "tmp", "bootstrap-#{uuid}")
  end

  def command_prefix
    username == "root" ? "" : "sudo "
  end

  def command
    "bash -c 'chmod 0701 #{remote_script} && #{remote_script}'"
  end

  def defaults
    {
      :keys_only    => true,
      :config       => false,
      :auth_methods => %w( publickey ),
      :compression  => "zlib",
      :logger       => logger,
      :verbose      => Rails.configuration.log_level == :debug ? :verbose : :info
    }
  end

  def logger
    @logger ||= Rails.logger
  end

end
