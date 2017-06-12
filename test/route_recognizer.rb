class RouteRecognizer
  INITIAL_SEGMENT_REGEX = %r{^\/([^\/\(:]+)}
  EXCLUDED_CONTROLLERS = %w[assets dashboard about fact]
  attr_reader :controllers

  def initialize
    routes = Rails.application.routes.routes
    controllers = []
    routes.each do |route|
      action = route.defaults[:action]
      controller = route.defaults[:controller]
      next unless action == "index"
      next if controller =~ /^api|^rails/
      next if EXCLUDED_CONTROLLERS.include?(controller)
      controllers << controller
    end
    @controllers = contollers.uniq!
  end

  def model_for(controller)
    controller.classify.constantize
  end

  private
  attr_reader :routes
end
