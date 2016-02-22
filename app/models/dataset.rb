class Dataset < ActiveRecord::Base
  include ActionView::Helpers::TextHelper

  def fields_count
    csv_data.lines.first.split(',').count
  end
  def rows_count
    csv_data.lines.count-1 # subtract 1 to remove header
  end
  def description
    [pluralize( fields_count, 'field' ), pluralize( rows_count, 'rows' ) ].to_sentence
  end
end
