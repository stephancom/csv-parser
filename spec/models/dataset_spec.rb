require 'rails_helper'

RSpec.describe Dataset, type: :model do
  it { should have_db_column :title }
  it { should have_db_column :csv_data }
  it { should have_db_column :transformer }

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

      it { is_expected.to match(/#{fields_count} fields/i) }
      it { is_expected.to match(/#{rows_count} rows/i) }
    end
  end

  describe "transformer field" do
    describe "for new record" do
      let(:dataset) { dataset = Dataset.new }
      let(:default) { Dataset::AVAILABLE_TRANSFORMERS.keys.first }

      it "should default to plain" do
        expect(default).to eq('plain')
      end

      it "should be autofilled with the default" do
        expect(dataset.transformer).to eq(default)
      end
    end
    describe "when blank" do
      let(:dataset) { dataset = FactoryGirl.build :dataset, transformer: '' }
      let(:default) { Dataset::AVAILABLE_TRANSFORMERS.keys.first }

      it "should default to plain" do
        expect(default).to eq('plain')
      end

      it "should not be valid" do
        expect(dataset).not_to be_valid
      end
    end
    describe "when not a valid transformer type" do
      let(:dataset) { dataset = FactoryGirl.build :dataset, transformer: 'fnord' }
      let(:default) { Dataset::AVAILABLE_TRANSFORMERS.keys.first }

      it "should not be valid" do
        expect(dataset).not_to be_valid
      end
    end
  end

  describe "csv parsing" do
    shared_examples "it has the right format" do
      it "should be an array" do
        expect(parsed_data).to be_instance_of(Array)
      end
      it "should contain hashes" do
        expect(parsed_data).to all( be_instance_of(Hash) )
      end
      it "should contain the correct number of elements" do
        expect(parsed_data.count).to eq(dataset.rows_count)
      end
      it "should have the right keys in every row" do
        expect(parsed_data.map(&:keys)).to all( match_array(output_keys) )
      end
    end

    describe "random data" do
      let(:fields_count) { 4 }
      let(:rows_count) { 6 }
      let(:dataset) { FactoryGirl.create :dataset, csv_data: random_csv(fields_count, rows_count, "Parse%d"), transformer: 'plain' }

      describe "with simple parsing" do
        let(:parsed_data) { dataset.parsed_data }
        let(:output_keys) { %w(Parse1 Parse2 Parse3 Parse4)}

        it_behaves_like "it has the right format"
      end
    end
    describe "data provided in spec" do
      let(:fields_count) { 12 }
      let(:rows_count) { 14 }
      let(:csv_data) { IO.read(Rails.root.join("spec", "fixtures", "stock_items.csv")) }

      describe "with base parsing" do
        let(:dataset) { dataset = FactoryGirl.create :dataset, csv_data: csv_data, transformer: 'plain' }
        let(:parsed_data) { dataset.parsed_data }
        let(:output_keys) { [
          "item id", "description",
          "price", "cost", "price_type",
          "quantity_on_hand",
          "modifier_1_name", "modifier_1_price",
          "modifier_2_name", "modifier_2_price",
          "modifier_3_name", "modifier_3_price",
        ] }

        it_behaves_like "it has the right format"
      end

      describe "with stock item parsing" do
        let(:dataset) { dataset = FactoryGirl.create :dataset, csv_data: csv_data, transformer: :stock_item }
        let(:parsed_data) { dataset.parsed_data }
        let(:expected_json) { JSON.parse(IO.read(Rails.root.join("spec", "fixtures", "two_stock_items.json"))) }
        let(:output_keys) {["id", "description", "price", "cost", "price_type", "quantity_on_hand", "modifiers"]}
        # before(:all) do
        #   csv_data = IO.read(Rails.root.join("spec", "fixtures", "stock_items.csv"))
        #   @dataset = FactoryGirl.create :dataset, csv_data: csv_data, transformer: :stock_item
        # end

        describe "the text fixture" do
          it "should have multiple records" do
            expect(expected_json.size).to be >= 2
          end
          it "should have the right keys in the first record" do
            expect(expected_json.map(&:keys)).to all(match_array(output_keys))
          end
          it "should have the right keys" do
            expect(expected_json.map(&:keys)).to all(match_array(output_keys))
          end
        end

        describe "the resulting data" do
          it_behaves_like "it has the right format"

          describe "modifiers field" do
            let(:row_modifiers) { parsed_data.map { |row| row["modifiers"] } }
            it "must be an array" do
              expect(row_modifiers).to all(be_instance_of(Array))
            end

            it "must contain hashes" do
              row_modifiers.each do |these_modifiers|
                expect(these_modifiers).to all(be_instance_of(Hash))
              end
            end
          end          
        end
        # describe "the resulting data" do
        #   it "should have the right keys in the first record" do
        #     expect(parsed_data.first.keys).to match_array(output_keys)
        #   end
        #   xit "should have the right keys" do
        #     expect(parsed_data.map(&:keys)).to all(match_array(output_keys))
        #   end
        # end
      end

      describe "with builder presenter" do
        it "needs tests"
      end
    end
  end
end
