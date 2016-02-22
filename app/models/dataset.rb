require "CSV"
class Dataset < ActiveRecord::Base
  include ActionView::Helpers::TextHelper # handy for description

  validates :csv_data, presence: true

  # parsing
  def parsed_data
    @parsed_data ||= CSV.parse(csv_data, headers: true).map(&:to_hash)
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
end
