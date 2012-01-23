class ComputeResourcesController < ApplicationController
  include Foreman::Controller::AutoCompleteSearch
  before_filter :find_by_id, :only => %w{show edit update destroy}

  def index
    values = ComputeResource.search_for(params[:search], :order => params[:order])
    respond_to do |format|
      format.html {@compute_resources = values.paginate :page => params[:page]}
      format.json {render :json => ComputeResource.all}
    end
  end

  def new
    @compute_resource = ComputeResource.new
  end

  def create
    @compute_resource = ComputeResource.new_provider params[:compute_resource]
    if @compute_resource.save
      process_success
    else
      process_error
    end
  end

  def edit
  end

  def update
    if @compute_resource.update_attributes(params[:compute_resource])
      process_success
    else
      process_error
    end
  end

  def destroy
    if @compute_resource.destroy
      process_success
    else
      process_error
    end
  end
  private

  def find_by_id
    @compute_resource = ComputeResource.find(params[:id])
  end
end
