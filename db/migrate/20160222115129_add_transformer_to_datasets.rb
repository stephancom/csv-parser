class AddTransformerToDatasets < ActiveRecord::Migration
  def up
    add_column :datasets, :transformer, :string

    Dataset.reset_column_information

    Dataset.all.each { |d| d.update_column( :transformer, Dataset::AVAILABLE_TRANSFORMERS.keys.first ) }
  end

  def down
    remove_column :datasets, :transformer
  end
end
