module APIv2
  module Entities
    class MarketTicker < Base
      # expose :id, documentation: "Unique market id. It's always in the form of xxxyyy, where xxx is the base currency code, yyy is the quote currency code, e.g. 'ltcbtc'. All available markets can be found at /api/v2/markets."

      expose :id
    end
  end
end
