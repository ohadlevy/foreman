::SecureHeaders::Configuration.configure do |config|
  config.hsts = {
    :max_age            => 20.years.to_i,
    :include_subdomains => true
  }
  config.x_frame_options = 'SAMEORIGIN'
  config.x_content_type_options = "nosniff"
  config.x_xss_protection = {
    :value => 1,
    :mode  => 'block'
  }
  config.csp = {
    :enforce     => true,
    :default_src => 'self',
    :frame_src   => 'self',
    :connect_src => %w(self ws: wss:),
    :style_src   => 'inline self',
    :script_src  => %w(eval inline self),
    :img_src     => %w(self *.gravatar.com)
  }
  if Rails.env.development?
    config.csp[:script_src] << 'http://localhost:3808'
    config.csp[:connect_src] << 'http://localhost:3808'
  end
end
