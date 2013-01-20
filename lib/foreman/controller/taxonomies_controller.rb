module Foreman::Controller::TaxonomiesController
  extend ActiveSupport::Concern

  included do
    before_filter :find_taxonomy, :only => %w{edit update destroy clone assign_hosts
                                            assign_selected_hosts assign_all_hosts step2}
    before_filter :count_nil_hosts, :only => %w{index create step2}
    skip_before_filter :authorize, :set_taxonomy, :only => %w{select}
  end

  module InstanceMethods
    private
    def taxonomy_id
      case controller_name
        when 'organizations'
          :organization_id
        when 'locations'
          :location_id
      end
    end

    def find_taxonomy
      case controller_name
        when 'organizations'
          @organization = Organization.find(params[:id])
        when 'locations'
          @location = Location.find(params[:id])
      end
    end

    def count_nil_hosts
      return @count_nil_hosts if @count_nil_hosts
      @count_nil_hosts = Host.where(taxonomy_id => nil).count
    end

  end
end