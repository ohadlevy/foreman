class ImagesController < ApplicationController
  include Foreman::Controller::AutoCompleteSearch
  before_filter :find_by_name, :only => %w{show edit update destroy}

  def index
    values = Image.search_for(params[:search], :order => params[:order])
    respond_to do |format|
      format.html { @images = values.paginate :page => params[:page] }
      format.json { render :json => values }
    end
  end

  def new
    @image = Image.new
  end

  def show
    respond_to do |format|
      format.json { render :json => @image }
    end
  end

  def create
    @image = Image.new(params[:image])
    if @image.save
      process_success
    else
      process_error
    end
  end

  def edit
  end

  def update
    if @image.update_attributes(params[:image])
      process_success
    else
      process_error
    end
  end

  def destroy
    if @image.destroy
      process_success
    else
      process_error
    end
  end

end
