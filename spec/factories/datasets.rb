FactoryGirl.define do
  factory :dataset do
    title "MyString"
    csv_data <<-EOCSV
      one, two
      123, 456
    EOCSV
  end
end
