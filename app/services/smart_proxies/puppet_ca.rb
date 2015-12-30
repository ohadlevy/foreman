require "time"

class SmartProxies::PuppetCA
  attr_reader :name, :state, :fingerprint, :valid_from, :expires_at, :puppet_ca

  def initialize(opts)
    @name, @state, @fingerprint, @valid_from, @expires_at, @smart_proxy_id = opts.flatten
    @valid_from = Time.parse(@valid_from) unless @valid_from.blank?
    @expires_at = Time.parse(@expires_at) unless @expires_at.blank?
  end

  def sign
    raise ::Foreman::Exception.new(N_("unable to sign a non pending certificate")) unless state == "pending"
    puppet_ca.revoke_cache!
    puppet_ca.sign(name)
  end

  def destroy
    puppet_ca.revoke_cache!
    puppet_ca.destroy(name)
  end

  def to_s; name end

  def <=>(other)
    self.name <=> other.name
  end

end