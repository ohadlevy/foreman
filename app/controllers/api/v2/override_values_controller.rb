module Api
  module V2
    class OverrideValuesController < V2::BaseController
      include Api::Version2

      before_filter :find_resource, :only => [:show, :update, :destroy]
      before_filter :find_required_nested_object, :only => [:index, :create]

      api :GET, '/smart_variables/:smart_variable_id/override_values', 'List of override values for a specific smart_variable'
      api :GET, '/smart_class_parameter/:smart_class_parameter_id/override_values', 'List of override values for a specific smart class parameter'
      param :smart_variable_id, :identifier, :required => false
      param :smart_class_parameter_id, :identifier, :required => false
      param :page, String, :desc => 'paginate results'
      param :per_page, String, :desc => 'number of entries per request'

      def index
        @override_values = nested_obj.lookup_values.paginate(paginate_options)
      end

      api :GET, '/smart_variables/:smart_variable_id/override_values/:id', 'Show an override value for a specific smart_variable'
      api :GET, '/smart_class_parameter/:smart_class_parameter_id/override_values/:id', 'Show an override value for a specific smart class parameter'
      param :smart_variable_id, :identifier, :required => false
      param :smart_class_parameter_id, :identifier, :required => false
      param :id, :identifier, :required => true

      def show
        @override_value = @lookup_value
      end

      api :POST, '/smart_variables/:smart_variable_id/override_values', 'Create an override value for a specific smart_variable'
      api :POST, '/smart_class_parameters/:smart_class_parameter_id/override_values', 'Create an override value for a specific smart class parameter'
      param :smart_variable_id, :identifier, :required => true
      param :override_value, Hash, :required => true do
        param :match, String
        param :value, String
      end

      def create
        @override_value = nested_obj.lookup_values.create!(params[:override_value])
      end

      api :PUT, '/smart_variables/:smart_variable_id/override_values', 'Update an override value for a specific smart_variable'
      api :PUT, '/smart_class_parameters/:smart_class_parameter_id/override_values', 'Update an override value for a specific smart class parameter'
      param :smart_variable_id, :identifier, :required => true
      param :override_value, Hash, :required => true do
        param :match, String
        param :value, String
      end

      def update
        @override_value = @lookup_value
        process_response @override_value.update_attributes(params[:override_value])
      end

      api :DELETE, '/smart_variables/:id', 'Delete a smart variable.'
      api :DELETE, '/smart_class_parameters/:id', 'Delete a smart class parameter.'
      param :id, :identifier, :required => true

      def destroy
        @override_value = @lookup_value
        process_response @override_value.destroy
      end

      private

      def allowed_nested_id
        %w(smart_class_parameter_id smart_variable_id)
      end

      def skip_nested_id
        %w(puppetclass_id environment_id)
      end

      # overwrite Api::BaseController
      def resource_name
        'lookup_value'
      end

    end
  end
end