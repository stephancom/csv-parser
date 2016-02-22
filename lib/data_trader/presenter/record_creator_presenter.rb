# this is an untested concept for a record builder class
# just a sketch.  It expects a class that has a create class method
# (for example, an ActiveRecord model) and calls create for each
# row with the hash for that row
# typical usage:

# @importer = DataTrader::Importer::CSVImporter.new(csv_data)
# @transformer = DataTrader::Transformer::User.new(require_email: true)
# @presenter = DataTrader::Presenter::RecordCreatorPresenter.new(User)
# trader = DataTrader::Agent.new @importer
# trader.trade

module DataTrader::Presenter
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

