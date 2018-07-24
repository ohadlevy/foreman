class TemplatesController < ApplicationController
  include UnattendedHelper # includes also Foreman::Renderer
  include Foreman::Controller::ProvisioningTemplates
  include Foreman::Controller::AutoCompleteSearch
  include AuditsHelper

  before_action :handle_template_upload, :only => [:create, :update]
  before_action :find_resource, :only => [:edit, :update, :destroy, :clone_template, :lock, :unlock, :export]
  before_action :load_history, :only => :edit
  before_action :type_name_plural, :type_name_singular, :resource_class

  include TemplatePathsHelper

  def index
    @templates = resource_base_search_and_page
    @templates = @templates.includes(resource_base.template_includes)
  end

  def new
    @template = resource_class.new
  end

  # we can't use `clone` here, ActionController disables public method that are inherited and present in Base
  # parent classes (so all controllers don't have actions like id, clone, dup, ...), unfortunatelly they don't
  # detect method definitions in controller ancestors, only methods defined directly in child controller
  def clone_template
    @template = @template.dup
    @template.name += ' clone'
    @template.locked = false
    load_vars_from_template
    @template.valid?
    render :action => :new
  end

  def lock
    set_locked true
  end

  def unlock
    set_locked false
  end

  def create
    @template = resource_class.new(resource_params)
    if @template.save
      process_success :object => @template
    else
      process_error :object => @template
    end
  end

  def edit
    load_vars_from_template
  end

  def update
    result = @template.update(resource_params)
    if ajax?
      ajax_response_for_update(result, @template)
    else
      if result
        process_success :object => @template
      else
        load_history
        process_error :object => @template
      end
    end
  end

  def revision
    audit = Audit.find(params[:version])
    render :json => audit.revision.template
  end

  def destroy
    if @template.destroy
      process_success :object => @template
    else
      process_error :object => @template
    end
  end

  def auto_complete_controller_name
    type_name_plural
  end

  def preview
    # Not using before_action :find_resource method because we have enabled preview to work for unsaved templates hence no resource could be found in those cases
    if params[:id]
      find_resource
    else
      @template = resource_class.new(params[type_name_plural])
    end
    base = @template.class.preview_host_collection
    @host = params[:preview_host_id].present? ? base.find(params[:preview_host_id]) : base.first
    if @host.nil?
      render :plain => _('No host could be found for rendering the template'), :status => :not_found
      return
    end
    @template.template = params[:template]
    safe_render(@template)
  end

  def export
    send_data @template.to_erb, :type => 'text/plain', :disposition => 'attachment', :filename => @template.filename
  end

  def resource_class
    @resource_class ||= controller_name.singularize.classify.constantize
  end

  def resource_name
    'template'
  end

  private

  def safe_render(template)
    load_template_vars
    render :plain => unattended_render(template)
  rescue => error
    Foreman::Logging.exception("Error rendering the #{template.name} template", error)
    if error.is_a?(Foreman::Renderer::RenderingError)
      text = error.message
    else
      text = _("There was an error rendering the %{name} template: %{error}") % {:name => template.name, :error => error.message}
    end

    render :plain => text, :status => :internal_server_error
  end

  def ajax_response_for_update(result, template)
    if result
      render :json => {
        :status => 'success',
        :message => _("Successfully updated %s.") % template.to_s,
        :success_redirect => request.referer }, :status => :ok
    else
      logger.error "Failed to save: #{template.errors.full_messages.join(', ')}" if template.respond_to?(:errors)
      message ||= [template.errors[:base] + template.errors[:conflict].map{|e| _("Conflict - %s") % e}].flatten
      message = [message].flatten.to_sentence
      render :json => {
        :status => 'failure',
        :message => message,
        :success_redirect => request.referer }, :status => :unprocessable_entity
    end
  end

  def set_locked(locked)
    @template.locked = locked
    if @template.save
      process_success :success_msg => (locked ? _('Template locked') : _('Template unlocked')), :success_redirect => :back, :object => @template
    else
      process_error :object => @template
    end
  end

  def load_history
    return unless @template
    @history = Audit.descending
                    .where(:auditable_id => @template.id,
                           :auditable_type => @template.class.base_class.name,
                           :action => 'update')
                    .select { |audit| audit_template? audit }
  end

  def action_permission
    case params[:action]
      when 'lock', 'unlock'
        :lock
      when 'clone_template', 'preview', 'export'
        :view
      else
        super
    end
  end

  def type_name_plural
    @type_name_plural ||= type_name_singular.pluralize
  end

  def resource_params
    public_send "#{type_name_singular}_params".to_sym
  end
end
