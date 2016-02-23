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
  end

  describe "example record one" do
    let(:csv_parse) { 
      { "item id" => 111010, "description" => "Coffee", "quantity_on_hand" => 100000,
        "price" => "$1.25", "cost" => "$0.80", "price_type" => "system",
        "modifier_1_name"  =>  "Small", "modifier_1_price" => "-$0.25",
        "modifier_2_name"  => "Medium", "modifier_2_price" =>  "$0.00",
        "modifier_3_name"  =>  "Large", "modifier_3_price" =>  "$0.30"  }
      }

    it_behaves_like "it has the right format"
  end

  describe "example record two" do
    let(:csv_parse) { 
      { "item id" => 111784, "description" => "Delivery", "quantity_on_hand" => '',
        "price" => "", "cost" => "", "price_type" => "system",
        "modifier_1_name" => "", "modifier_1_price" => "",
        "modifier_2_name" => "", "modifier_2_price" => "",
        "modifier_3_name" => "", "modifier_3_price" => ""  }
    }

    it_behaves_like "it has the right format"
  end
end