json.array!(@datasets) do |dataset|
  json.extract! dataset, :id, :title, :csv_data
  json.url dataset_url(dataset, format: :json)
end
