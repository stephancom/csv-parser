# transformer modules must implement a transform_row class method
# which takes a hash as input and returns a different hash
module DataTrader::Transformer 
  class Base
    def transform_row(row)
      row
    end
  end
end
