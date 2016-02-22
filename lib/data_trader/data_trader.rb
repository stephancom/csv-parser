module DataTrader
  class Agent
    def initialize(importer, args={})
      @importer = importer
      @transformer = args[:transformer] || DataTrader::Transformer::Base.new
      @presenter = args[:presenter] || DataTrader::Presenter::Base.new
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
