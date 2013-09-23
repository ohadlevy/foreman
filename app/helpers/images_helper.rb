module ImagesHelper
  def image_field f
    return unless @compute_resource.capabilities.include?(:image)
    if images.any?
      select_f(f, :uuid, images, :id, :name, {}, :label => _('Image'))
    else
      text_f f, :uuid, :label => _('Image ID'), :help_inline => _('Image ID as provided by the compute resource, e.g. ami-..')
    end
  end

  private

  # not all providers supports sorting for images, handling it generically here:
  def images
    @sorted_images ||= @compute_resource.available_images.
      delete_if {|i| i.name.nil? }.
      sort { |a, b| a.name.downcase <=> b.name.downcase }
  end
end
