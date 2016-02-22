require 'csv'
class Dataset < ActiveRecord::Base
  include ActionView::Helpers::TextHelper # handy for description

  validates :csv_data, presence: true

  after_create :create_importer

  # parsing
  def parsed_data
    trader = DataTrader::Agent.new @importer
    @parsed_data ||= trader.trade #CSV.parse(csv_data, headers: true).map(&:to_hash)
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

  def create_importer
    @importer = DataTrader::Importer::CSVImporter.new(csv_data)
  end
end
