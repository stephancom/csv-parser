# returns JSON for the array of hashes

module DataTrader::Presenter
  class JSONPresenter < Base
    def present(hashes)
      hashes.to_json
    end
  end
end

