module Api
  module V2
    class SmartClassParametersController < V2::BaseController
      include Api::Version2
      include Api::V2::LookupKeysCommonController

      before_filter :find_resource, :only => [:show, :update, :destroy]
      before_filter :find_optional_nested_object, :only => :index
      before_filter :find_environment, :only => :index
      before_filter :find_puppetclass, :only => :index

      api :GET, '/smart_class_parameters', 'List all smart class parameters'
      api :GET, '/hosts/:host_id/smart_class_parameters', 'List of smart class parameters for a specific host'
      api :GET, '/hostgroups/:hostgroup_id/smart_class_parameters', 'List of smart class parameters for a specific hostgroup'
      api :GET, '/puppetclasses/:puppetclass_id/smart_class_parameters', 'List of smart class parameters for a specific puppetclass'
      api :GET, '/environments/:environment_id/smart_class_parameters', 'List of smart class parameters for a specific environment'
      api :GET, '/environments/:environment_id/puppetclasses/:puppetclass_id/smart_class_parameters', 'List of smart class parameters for a specific environment/puppetclass combination'
      param :host_id, :identifier, :required => false
      param :hostgroup_id, :identifier, :required => false
      param :puppetclass_id, :identifier, :required => false
      param :environment_id, :identifier, :required => false
      param :search, String, :desc => 'Filter results'
      param :order, String, :desc => 'sort results'
      param :page, String, :desc => 'paginate results'
      param :per_page, String, :desc => 'number of entries per request'

      def index
        if nested_obj && nested_obj.kind_of?(Host::Base) || nested_obj.kind_of?(Hostgroup)
          puppetclass_ids         = nested_obj.all_puppetclasses.map(&:id)
          environment_id          = nested_obj.environment_id
          @smart_class_parameters = LookupKey.parameters_for_class(puppetclass_ids, environment_id).search_for(*search_options).paginate(paginate_options)
        elsif @puppetclass && @environment
          @smart_class_parameters = LookupKey.smart_class_parameters_for_class(@puppetclass.id, @environment.id).search_for(*search_options).paginate(paginate_options)
        elsif @puppetclass && !@environment
          environment_ids         = Environment.pluck(:id)
          @smart_class_parameters = LookupKey.smart_class_parameters_for_class(@puppetclass.id, environment_ids).search_for(*search_options).paginate(paginate_options)
        elsif !@puppetclass && @environment
          puppetclass_ids         = Puppetclass.pluck(:id)
          @smart_class_parameters = LookupKey.smart_class_parameters_for_class(puppetclass_ids, @environment.id).search_for(*search_options).paginate(paginate_options)
        else
          @smart_class_parameters = LookupKey.smart_class_parameters.search_for(*search_options).paginate(paginate_options)
        end
      end

      # no create action for API
      # smart class parameters are imported by PuppetClassImporter

      api :GET, '/smart_class_parameters/:id/', 'Show a smart class parameter.'
      param :id, :identifier, :required => true

      def show
        @smart_class_parameter = @lookup_key
        render 'api/v2/smart_class_parameters/show'
      end


      api :PUT, '/smart_class_parameters/:id', 'Update a smart class parameter.'
      param :id, :identifier, :required => true
      param :smart_class_parameter, Hash, :required => true do
        # can't update parameter/key name for :parameter, String, :required => true
        param :override, :bool
        param :description, String
        param :default_value, String
        param :path, String
        param :validator_type, String
        param :validator_rule, String
        param :override_value_order, String
        param :parameter_type, String
        param :required, :bool
      end

      def update
        @smart_class_parameter = @lookup_key
        # TODO - add callback to update :override to true if any parameters are updated except description
        process_response @smart_class_parameter.update_attributes(params[:smart_class_parameter])
      end

      def destroy
        @smart_class_parameter = @lookup_key
        process_response @smart_class_parameter.destroy
      end

      private

      def find_environment
        if params[:environment_id]
          resource_identifying_attributes.each do |key|
            find_method  = "find_by_#{key}"
            @environment ||= Environment.send(find_method, params[:environment_id])
          end
          return @environment if @environment
        end
      end

    end
  end
end