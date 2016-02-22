# presenter modules accept an array of hashes at initialization
# they must implement a "present" method which accepts
# an array of hashes and returns or does whatever is expected
# e.g. a JSONpresenter returns a JSON string
# another presenter might create records, etc.
module DataTrader::Presenter
  class Base
    def present(hashes)
      hashes
    end
  end
end
