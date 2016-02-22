require 'csv'
class Dataset < ActiveRecord::Base
  include ActionView::Helpers::TextHelper # handy for description

  AVAILABLE_TRANSFORMERS = {
    'plain' => DataTrader::Transformer::Base,
    'stock_item' => StockItemTransformer
  }

  validates :csv_data, presence: true
  validates :transformer, presence: true, inclusion: {in: AVAILABLE_TRANSFORMERS.keys} 

  after_initialize :set_default_transformer

  # parsing
  def parsed_data
    trader = DataTrader::Agent.new get_importer, get_transformer: transformer
    @parsed_data ||= trader.trade
  end

  # handy helpers - some might argue these belong in helpers for use in the view
  # but I find it useful to keep them in the model so they can be used elsewhere
  # eg rake tasks, etc.
  def field_names
    csv_data.lines.first.split(',')
  end
  def fields_count
    field_names.count
  end
  def rows_count
    csv_data.lines.count-1 # subtract 1 to remove header
  end
  def description
    [pluralize( fields_count, 'field' ), pluralize( rows_count, 'rows' ) ].to_sentence
  end

  private

  def set_default_transformer
    self.transformer ||= AVAILABLE_TRANSFORMERS.keys.first if new_record?
  end

  def get_importer
    @get_importer = DataTrader::Importer::CSVImporter.new(csv_data)
  end

  def get_transformer
    @get_transformer = AVAILABLE_TRANSFORMERS[transformer].new
  end
end
