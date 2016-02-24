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

  # references for solving this problem:
  # http://stackoverflow.com/questions/7081782/inconsistent-loaderror-behavior-with-lib-namespacing-autoloading

  # http://stackoverflow.com/questions/19098663/auto-loading-lib-files-in-rails-4
  # http://www.williambharding.com/blog/technology/rails-3-autoload-modules-and-classes-in-production/
  # http://urbanautomaton.com/blog/2013/08/27/rails-autoloading-hell/#fn1
  # https://github.com/krautcomputing/services/issues/1
  # http://edgeguides.rubyonrails.org/autoloading_and_reloading_constants.html#when-constants-aren-t-missed
  # http://stackoverflow.com/questions/24545602/rails-unable-to-autoload-constant-from-file-despite-being-defined-in-that-file
  # http://stackoverflow.com/questions/24331892/loaderror-unable-to-autoload-constant-message
  # https://www.google.com/search?client=safari&rls=en&q=Unable+to+autoload+constant+expected+to+define+it&ie=UTF-8&oe=UTF-8#q=in+some+rspec+tests+%22Unable+to+autoload+constant%22+expected+%22to+define+it%22
  # http://stackoverflow.com/questions/19098663/auto-loading-lib-files-in-rails-4
  # http://stackoverflow.com/questions/3356742/best-way-to-load-module-class-from-lib-folder-in-rails-3
  # http://stackoverflow.com/questions/17951037/how-to-require-some-lib-files-from-anywhere
  # http://stackoverflow.com/questions/28971876/rails-how-to-require-files-from-lib-folder-in-order-to-use-them-in-controllers
  # http://stackoverflow.com/questions/19098663/auto-loading-lib-files-in-rails-4
  # https://gist.github.com/maxim/6503591

  # http://vrybas.github.io/blog/2014/08/15/a-way-to-organize-poros-in-rails/
  # http://www.benfranklinlabs.com/where-to-put-rails-modules/
  # http://brewhouse.io/blog/2014/04/30/gourmet-service-objects.html
  # http://www.justinweiss.com/articles/where-do-you-put-your-code/
  # https://dockyard.com/blog/ruby/2012/02/14/love-your-lib-directory
  # http://blog.codeclimate.com/blog/2012/02/07/what-code-goes-in-the-lib-directory/

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
