class StockItemTransformer < DataTrader::Transformer::Base
  UNCHANGED_KEYS = ["cost", "description", "price", "price_type", "quantity_on_hand"]

  def initialize(modifiers_count = 3)
    @modifiers_count = modifiers_count
  end

  def nth_modifier(row, n)
    {"name" => row["modifier_#{n}_name"], "price" => row["modifier_#{n}_price"]}
  end

  # returns an array of modifiers
  def extract_modifiers(row)
    (1..@modifiers_count).inject([]) do |mods, n|
      mods << nth_modifier(row, n)
    end
  end

  def transform_row(row)
    row.slice(*UNCHANGED_KEYS).tap do |item|
      item['id'] = row["item id"]
      item['modifiers'] = extract_modifiers(row)
    end
  end
end
