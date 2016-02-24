require 'rails_helper'

RSpec.describe StockItemTransformer, type: :model do
  let(:stock_transformer) { StockItemTransformer.new }
  let(:parsed_data) { stock_transformer.transform_row(csv_parse) }
  let(:output_keys) {["id", "description", "price", "cost", "price_type", "quantity_on_hand", "modifiers"]}

  shared_examples "it has the right format" do
    it "should be a hash" do
      expect(parsed_data).to be_instance_of(Hash)
    end
    it "should have the right keys" do
      expect(parsed_data.keys).to match_array(output_keys)
    end
    it "modifiers should be an array" do
      expect(parsed_data["modifiers"]).to be_instance_of(Array)
    end
    it "should have the right result" do
      expect(JSON.parse parsed_data.to_json).to match(JSON.parse result.to_json)
    end
  end

  describe "example record one" do
    let(:csv_parse) { 
      { "item id" => 111010, "description" => "Coffee", "quantity_on_hand" => 100000,
        "price" => "$1.25", "cost" => "$0.80", "price_type" => "system",
        "modifier_1_name"  =>  "Small", "modifier_1_price" => "-$0.25",
        "modifier_2_name"  => "Medium", "modifier_2_price" =>  "$0.00",
        "modifier_3_name"  =>  "Large", "modifier_3_price" =>  "$0.30"  }
      }
    let(:result) { 
      { "id" => 111010, "description" => "Coffee", "quantity_on_hand" => 100000,
        "price" => 1.25, "cost" => 0.80, "price_type" => "system",
        "modifiers" => [
          { "name" => "Small", "price" => -0.25 },
          { "name" => "Medium", "price" => 0.00 },
          { "name" => "Large", "price" => 0.30  }]}
     }

    it_behaves_like "it has the right format"
  end

  describe "example record two" do
    let(:csv_parse) { 
      { "item id" => 111784, "description" => "Delivery", "quantity_on_hand" => '',
        "price" => "", "cost" => "", "price_type" => "open",
        "modifier_1_name" => "", "modifier_1_price" => "",
        "modifier_2_name" => "", "modifier_2_price" => "",
        "modifier_3_name" => "", "modifier_3_price" => ""  }
    }
    let(:result) { 
      { "id" => 111784, "description" => 'Delivery', "quantity_on_hand" => nil,
        "price" => nil, "cost" => nil, "price_type" => 'open',
        "modifiers" => [] }
    }

    it_behaves_like "it has the right format"
  end

  # testing private methods
  # which is supposed to be a no-no but I'm trying to debug them
  describe "currency parse" do
    it "should return nil for blank" do
      expect(stock_transformer.send(:currency, '')).to be_nil
    end
    it "should transform a currency to float" do
      expect(stock_transformer.send(:currency, '$1.30')).to eq(1.3)
    end
    it "should handle a negative sign before the currency symbol" do
      expect(stock_transformer.send(:currency, '-$2.34')).to eq(-2.34)
    end
  end
  describe "blank filter" do
    it "should return nil for blank" do
      expect(stock_transformer.send(:unless_blank, '')).to be_nil
    end
    it "should return its value" do
      expect(stock_transformer.send(:unless_blank, 'St3ph4n')).to eq('St3ph4n')
    end
  end
  describe "modifier extractor" do  
    describe "single" do
      let(:input_data) { {
        "modifier_5_name" => "With chips", "modifier_5_price" => "$0.75",
        "modifier_6_name" => "",           "modifier_6_price" => "",
        # it's not clear from the spec if these should return nil or not
        "modifier_7_name" => "With pickle","modifier_7_price" => "",
        "modifier_8_name" => "",           "modifier_8_price" => "$0.25",
        "modifier_9_name" => "Wearing Cubs hat",           "modifier_9_price" => "-$1.00",
      } }
      it "should return a proper hash with good data" do
        expect(stock_transformer.send(:nth_modifier, input_data, 5)).to match({"name" => "With chips", "price" => 0.75})
      end
      it "should return nil with both fields blank" do
        expect(stock_transformer.send(:nth_modifier, input_data, 6)).to be_nil
      end
      # I'm going to guess that a blank name means skip it, blank price means keep the name, price is 0
      it "should return price nil if price is blank" do
        expect(stock_transformer.send(:nth_modifier, input_data, 7)).to match({"name" => "With pickle", "price" => nil})
      end
      it "should return nil with name blank" do
        expect(stock_transformer.send(:nth_modifier, input_data, 8)).to be_nil
      end
      it "should handle negative price" do
        expect(stock_transformer.send(:nth_modifier, input_data, 9)).to match({"name" => "Wearing Cubs hat", "price" => -1})
      end
    end

    describe "collection" do
      it "should return three good records if three are present" do
        modifiers = {
          "modifier_1_name" => "Small", "modifier_1_price" => "-$1.00",
          "modifier_2_name" => "Medium","modifier_2_price" => "$0.00",
          "modifier_3_name" => "Large", "modifier_3_price" => "$0.75"
        }
        expected_result = [
          {"name" => "Small",   "price" => -1},
          {"name" => "Medium",  "price" => 0},
          {"name" => "Large",   "price" => 0.75}
        ]
        expect(stock_transformer.send(:extract_modifiers, modifiers)).to match(expected_result)
      end
      it "should return two records if one has no name and one has no price" do
        modifiers = {
          "modifier_1_name" => "", "modifier_1_price" => "-$1.00",
          "modifier_2_name" => "Medium","modifier_2_price" => "",
          "modifier_3_name" => "Large", "modifier_3_price" => "$0.75"
        }
        expected_result = [
          {"name" => "Medium",  "price" => nil},
          {"name" => "Large",   "price" => 0.75}
        ]
        expect(stock_transformer.send(:extract_modifiers, modifiers)).to match(expected_result)
      end
      it "should return two records if one is totally absent and the other lacks a price field" do
        modifiers = {
          "modifier_1_name" => "Medium",
          "modifier_3_name" => "Large", "modifier_3_price" => "$0.75"
        }
        expected_result = [
          {"name" => "Medium",  "price" => nil},
          {"name" => "Large",   "price" => 0.75}
        ]
        expect(stock_transformer.send(:extract_modifiers, modifiers)).to match(expected_result)
      end
      it "should return an empty hash if all three are blank" do
        modifiers = {
          "modifier_1_name" => "", "modifier_1_price" => "",
          "modifier_2_name" => "", "modifier_2_price" => "",
          "modifier_3_name" => "", "modifier_7_price" => ""
        }
        expect(stock_transformer.send(:extract_modifiers, modifiers)).to eq([])
      end
    end
  end
end












