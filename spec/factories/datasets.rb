FactoryGirl.define do
  factory :dataset do
    title "A Data Upload"
    transformer "stock_item"
    csv_data <<-EOCSV
      one, two
      123, 456
    EOCSV
  end
end
