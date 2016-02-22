require 'rails_helper'

RSpec.describe Dataset, type: :model do
  it { should have_db_column :title }
  it { should have_db_column :csv_data }

  describe "csv field" do
    let(:fields_count) { rand(4) + rand(4) + 2 }
    let(:rows_count) { rand(6) + rand(6) + 2 }
    let(:dataset) { FactoryGirl.create :dataset, csv_data: random_csv(fields_count, rows_count, "SeeEssVee%d") }

    it "should be invalid when blank" do
      dataset = FactoryGirl.build :dataset, csv_data: ''
      expect(dataset).not_to be_valid
    end

    it "should count the lines in the field" do
      expect(dataset.rows_count).to eq(rows_count)
    end

    it "should return the right fields" do
      dataset.field_names.each_with_index do |field, i|
        expect(field.chomp).to eq("SeeEssVee#{i + 1}")
      end
    end

    it "should count the fields" do
      expect(dataset.fields_count).to eq(fields_count)      
    end

    describe "description" do
      subject { dataset.description }

      it { should match(/#{fields_count} fields/i) }
      it { should match(/#{rows_count} rows/i) }
    end
  end
end
