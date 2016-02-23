class StockItemTransformer < DataTrader::Transformer::Base
  UNCHANGED_KEYS = ["cost", "description", "price", "price_type", "quantity_on_hand"]

  def initialize(modifiers_count = 3)
    @modifiers_count = modifiers_count
  end

  def extract_modifier(row, n)
    {"name" => row["modifier_#{n}_name"], "price" => row["modifier_#{n}_price"]}
  end

  def transform_row(row)
    row.slice(*UNCHANGED_KEYS).tap do |item|
      item['id'] = row["item id"]
      item['modifiers'] = [].tap do |modifiers|
        # puts item['modifiers']
        (1..@modifiers_count).map { |n| extract_modifier(row, n) } .each do |modifier|
          modifiers << modifier unless modifier.values.all?(&:blank?)
        end
      end
    end
  end
end
