require 'csv'
module DataTrader

  class Agent
    def initialize(importer, args={})
      @importer = importer
      @transformer = args[:transformer] || Transformer::Base.new
      @presenter = args[:presenter] || Presenter::Base.new
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

  # IMPORTANT NOTE:
  # I would prefer to put all these supporting modules in separate files
  # eg data_trader/transformer/base.rb
  # for some reason, this causes a LoadError on SOME rspec tests - which ones
  # depends on the test order when you use random order, for example:
  # Unable to autoload constant Transformer::Base, expected xxxxxxx/lib/data_trader/transformer/base.rb to define it
  # this may be related to FactoryGirl and/or Spring.  I wasted an hour or two trying to find a solution.


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

  # transformer modules must implement a transform_row method
  # which takes a hash as input and returns a different hash
  module Transformer  
    class Base
      def transform_row(row)
        row
      end
    end
  end

  # presenter modules must implement a "present" method which accepts
  # an array of hashes and returns or does whatever is expected
  # e.g. a JSONpresenter returns a JSON string
  module Presenter
    class Base
      def present(hashes)
        hashes
      end
    end

    class JSONPresenter < Base
      def present(hashes)
        hashes.to_json
      end
    end

    # just a sketch.  It expects a class that has a create class method
    # (for example, an ActiveRecord model) and calls create for each
    # row with the hash for that row
    # typical usage:
     
    # @importer = DataTrader::Importer::CSVImporter.new(csv_data)
    # @transformer = DataTrader::Transformer::User.new(require_email: true)
    # @presenter = DataTrader::Presenter::RecordCreatorPresenter.new(User)
    # trader = DataTrader::Agent.new @importer
    # trader.trade     
    class RecordCreatorPresenter < Base
      def initialize(target_class)
        @target_class
      end
      def present(hashes)
        hashes.each do |params|
          @target_class.create params
        end
      end
    end   
  end
end
