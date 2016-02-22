# I like using random tests.  Some people say to always be deterministic.
# I think it finds problems once in a while that wouldn't otherwise show up
# expects a count of DATA rows, not counting header
def random_csv(fields_count=3, rows_count=3, field_pattern="field%d")
  csv_array = [(1..fields_count).map { |i| field_pattern % i}.join(',')]
  rows_count.times do
    csv_array << (1..fields_count).map { |i| rand(9999) }.join(',')
  end
  csv_array.join("\n")
end