require 'csv'
module DataTrader
  # importer modules must implement a rows method returning an array of hashes
  # or at least some sort of enumerable that returns hashes
  # they typically accept as input a string of data, but this need not be so
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

  # transformer modules must implement a transform_row class method
  # which takes a hash as input and returns a different hash
  module Transformer  
    class Base
      def self.transform_row(row)
        row
      end
    end
  end

  # presenter modules accept an array of hashes at initialization
  # they must implement a "present" class method which accepts
  # an array of hashes and returns or does whatever is expected
  # e.g. a JSONpresenter returns a JSON string
  # another presenter might create records, etc.
  module Presenter
    class Base
      def self.present(hashes)
        hashes
      end
    end

    class JSONPresenter < Base
      def self.present
        hashes.to_json
      end
    end
  end

  class Agent
    def initialize(importer, args={})
      @importer = importer
      @transformer = args[:transformer] || Transformer::Base
      @presenter = args[:presenter] || Presenter::Base
    end

    def trade
      transformed = rows.map { |r| @transformer.transform_row(r) }
      @presenter.present(transformed)
    end

    private

    def rows
      @importer.rows
    end
  end
end
