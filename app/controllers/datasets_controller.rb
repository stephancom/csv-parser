class DatasetsController < ApplicationController
  before_action :set_dataset, only: [:show, :edit, :update, :destroy]

  respond_to :html
  respond_to :json, :xml, :yaml, only: :show

  def index
    @datasets = Dataset.all
    respond_with(@datasets)
  end

  def show
    format = (params[:format] || :html).downcase.to_s
    case format
    when 'json', 'xml', 'yaml'
      send_data @dataset.parsed_data.send('to_'+format), type: 'application/'+format, disposition: 'attachment', filename: 'dataset.'+format
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
