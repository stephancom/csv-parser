class DatasetsController < ApplicationController
  before_action :set_dataset, only: [:show, :edit, :update, :destroy]

  respond_to :html, :json

  def index
    @datasets = Dataset.all
    respond_with(@datasets)
  end

  def show
    # TODO - fix this quickie hack
    if params[:format] and params[:format].upcase == 'JSON'
      send_data @dataset.parsed_data, type: 'application/json', disposition: 'attachment', filename: "dataset.json"
    else    
      respond_with(@dataset)
    end
  end

  def new
    @dataset = Dataset.new
    respond_with(@dataset)
  end

  def edit
  end

  def create
    @dataset = Dataset.new(dataset_params)
    @dataset.save
    respond_with(@dataset)
  end

  def update
    @dataset.update(dataset_params)
    respond_with(@dataset)
  end

  def destroy
    @dataset.destroy
    respond_with(@dataset)
  end

  private
    def set_dataset
      @dataset = Dataset.find(params[:id])
    end

    def dataset_params
      params.require(:dataset).permit(:title, :transformer, :csv_data)
    end
end
