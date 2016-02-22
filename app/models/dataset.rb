class Dataset < ActiveRecord::Base
  include ActionView::Helpers::TextHelper

  validates :csv_data, presence: true

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
