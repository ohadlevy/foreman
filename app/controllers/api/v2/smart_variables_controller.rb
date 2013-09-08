module Api
  module V2
    class SmartVariablesController < V2::BaseController
      include Api::Version2

      before_filter :find_resource, :only => [:show, :update, :destroy]
      before_filter :find_optional_nested_object, :only => [:index]
      before_filter :find_puppetclass, :only => [:create]

      api :GET, "/smart_variables", "List all smart variables"
      api :GET, "/hosts/:host_id/smart_variables", "List of smart variables for a specific host"
      api :GET, "/hostgroups/:hostgroup_id/smart_variables", "List of smart variables for a specific hostgroup"
      api :GET, "/puppetclasses/:puppetclass_id/smart_variables", "List of smart variables for a specific puppetclass"
      param :host_id, :identifier, :required => false
      param :hostgroup_id, :identifier, :required => false
      param :puppetclass_id, :identifier, :required => false
      param :search, String, :desc => "Filter results"
      param :order, String, :desc => "sort results"
      param :page, String, :desc => "paginate results"
      param :per_page, String, :desc => "number of entries per request"

      def index
        if nested_obj
          if nested_obj.kind_of?(Puppetclass)
            @smart_variables = LookupKey.global_parameters_for_class(nested_obj.id).search_for(*search_options).paginate(paginate_options)
          else  #host or hostgroup
            puppetclass_ids = nested_obj.all_puppetclasses.map(&:id)
            @smart_variables = LookupKey.global_parameters_for_class(puppetclass_ids).search_for(*search_options).paginate(paginate_options)
          end
        else
          @smart_variables = LookupKey.smart_variables.search_for(*search_options).paginate(paginate_options)
        end
        render 'api/v2/smart_variables/index'
      end

      api :GET, "/smart_variables/:id/", "Show a smart variable."
      api :GET, "/smart_class_parameters/:id/", "Show a smart class parameter)."
      param :id, :identifier, :required => true

      def show
        @smart_variable = @smart_class_parameter = @lookup_key
        if @lookup_key.is_smart_variable?
          render 'api/v2/smart_variables/show'
        else
          render 'api/v2/smart_class_parameters/show'
        end
      end

      api :POST, "/smart_variables", "Create a smart variable."
      param :smart_variable, Hash, :required => true do
        param :parameter, String, :required => true
        param :puppetclass_id, :number
        param :default_value, String
        param :override_value_order, String
        param :description, String
        param :validator_type, String
        param :validator_rule, String
        param :parameter_type, String
      end

      def create
        if @puppetclass
          @smart_variable = @puppetclass.lookup_keys.build(params[:smart_variable])
        else
          @smart_variable = LookupKey.new(params[:smart_variable])
        end
        @smart_variable.save!
        render 'api/v2/smart_variables/show'
      end

      api :PUT, "/smart_variables/:id", "Update a smart variable."
      param :id, :identifier, :required => true
      param :smart_variable, Hash, :required => true do
        param :parameter, String
        param :puppetclass_id, :number
        param :default_value, String
        param :override_value_order, String
        param :description, String
        param :validator_type, String
        param :validator_rule, String
        param :parameter_type, String
      end

      def update
        @smart_variable = @lookup_key
        process_response @smart_variable.update_attributes(params[:smart_variable])
      end

      api :DELETE, "/smart_variables/:id", "Delete a smart variable."
      param :id, :identifier, :required => true

      def destroy
        @smart_variable = @lookup_key
        process_response @smart_variable.destroy
      end

      private

      def find_puppetclass
        if params[:puppetclass_id]
          resource_identifying_attributes.each do |key|
            find_method = "find_by_#{key}"
            @puppetclass ||= Puppetclass.send(find_method, params[:puppetclass_id])
          end
          return @puppetclass if @puppetclass
        end
      end

      def allowed_nested_id
        %w(environment_id puppetclass_id host_id hostgroup_id)
      end

      # overwrite Api::BaseController
      def resource_name
        "lookup_key"
      end

    end
  end
end
