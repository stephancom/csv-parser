class StockItemTransformer < DataTrader::Transformer::Base
  UNCHANGED_KEYS = ["cost", "description", "price", "price_type", "quantity_on_hand"]

  def initialize(modifiers_count = 3)
    @modifiers_count = modifiers_count
  end

  def transform_row(row)
    # awww, this was so much prettier :(
    # row.slice(*UNCHANGED_KEYS).tap do |item|
    #   item['id'] = row["item id"]
    #   item['modifiers'] = extract_modifiers(row)
    # end

    # this is why I want to write a DSL next
    {}.tap do |item|
      item['id'] = row["item id"]
      item['description'] = unless_blank row['description']
      item['quantity_on_hand'] = integer row['quantity_on_hand']
      item['price_type'] = unless_blank row['price_type']
      item['price'] = currency row['price']
      item['cost']  = currency row['cost']
      item['modifiers'] = extract_modifiers(row)
    end
  end

  private
  
  def unless_blank(value)
    value unless value.blank?
  end
  # TODO I18n
  def currency(value)
    return nil if value.blank?
    value.tr('$','').to_f
  end

  def integer(value)
    value.to_i unless value.blank?
  end

  def nth_modifier(row, n)
    return nil if row["modifier_#{n}_name"].blank?
    {"name" => row["modifier_#{n}_name"], "price" => currency(row["modifier_#{n}_price"])}
  end

  # returns an array of modifiers
  def extract_modifiers(row)
    (1..@modifiers_count).inject([]) do |mods, n|
      mods << nth_modifier(row, n)
    end.compact
  end

end

