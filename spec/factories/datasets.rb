FactoryGirl.define do
  factory :dataset do
    title "A Data Upload"
    transformer "plain"
    csv_data <<-EOCSV
      one, two
      123, 456
    EOCSV
  end
end
