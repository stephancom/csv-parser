# sketch for DSL version of this:

# DataTrader::Transformer.define do
#   transformer :stock_items do
#     integer :id, source: :item_id, unique: true
#     string :description
#     currency :price
#     currency :cost
#     string :price_type, in: $w(system open)
#     integer :quantity_on_hand
#     children :modifiers do |n|
#       string :name, source: "modifier_%d_name"
#       currency :price, source: "modifier_%d_price"
#     end
#   end
# end

# references/resources for DSL
# https://robots.thoughtbot.com/writing-a-domain-specific-language-in-ruby
# https://www.leighhalliday.com/creating-ruby-dsl
# http://radar.oreilly.com/2014/04/make-magic-with-ruby-dsls.html
# http://yonkeltron.com/blog/2010/05/13/creating-a-ruby-dsl/
# http://engineering.gusto.com/benefits-of-writing-a-dsl/
# https://blog.atechmedia.com/ruby-dsls-for-fun/
# http://stackoverflow.com/questions/4936146/tutorials-for-writing-dsl-in-ruby
# https://shvets.github.io/blog/2013/11/16/two_simple_ruby_dsl_examples.html
# http://blog.pitr.ch/blog/2013/05/17/htmless-fast-extensible-html5-builder-in-pure-ruby/
# https://github.com/ms-ati/docile

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

