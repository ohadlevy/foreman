class LocationsController < ApplicationController
  include Foreman::Controller::AutoCompleteSearch
  before_filter :find_by_name, :only => %w{show edit update destroy}

  def index
    values = Location.search_for(params[:search], :order => params[:order])
    respond_to do |format|
      format.html { @locations = values.paginate :page => params[:page] }
      format.json { render :json => values }
    end
  end

  def new
    @location = Location.new
  end

  def show
    respond_to do |format|
      format.json { render :json => @location }
    end
  end

  def create
    @location = Location.new(params[:location])
    if @location.save
      process_success
    else
      process_error
    end
  end

  def edit
  end

  def update
    if @location.update_attributes(params[:location])
      process_success
    else
      process_error
    end
  end

  def destroy
    if @location.destroy
      process_success
    else
      process_error
    end
  end

end
