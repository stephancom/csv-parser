require 'csv'

# importer modules must implement a rows method returning an array of hashes
# or at least some sort of enumerable that returns hashes
# they typically accept as input a string of data, but this need not be so
module DataTrader
  module Importer
    class CSVImporter
      def initialize(data)
        @data = data
      end

      def rows
        CSV.parse(@data, headers: true).map(&:to_hash)
      end
    end
  end
end

