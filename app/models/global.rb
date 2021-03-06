class Global
  ZERO = '0.0'.to_d
  NOTHING_ARRAY = YAML::dump([])
  LIMIT = 80

  def initialize(currency)
    @currency = currency
  end

  def channel
    "market-#{@currency}-global"
  end

  attr_accessor :currency

  def self.[](market)
    if market.is_a? Market
      self.new(market.id)
    else
      self.new(market)
    end
  end

  def key(key, interval=5)
    seconds  = Time.now.to_i
    time_key = seconds - (seconds % interval)
    "peatio:#{@currency}:#{key}:#{time_key}"
  end

  def asks
    Rails.cache.read("peatio:#{currency}:depth:asks") || []
  end

  def bids
    Rails.cache.read("peatio:#{currency}:depth:bids") || []
  end

  def default_ticker
    {low: ZERO, high: ZERO, last: ZERO, volume: ZERO, change: ZERO, change_trend: ZERO}
  end

  def ticker
    ticker          = Rails.cache.read("peatio:#{currency}:ticker") || default_ticker
    best_buy_price  = bids.first && bids.first[0] || ZERO
    best_sell_price = asks.first && asks.first[0] || ZERO

    ticker.merge({
      volume: h24_volume,
      volume_btc: h24_volume_btc,
      change: h24_change,
      change_trend: change_trend,
      trend: trend,
      sell: best_sell_price,
      buy: best_buy_price,
      at: at,
    })
  end

  def trend
    Rails.cache.fetch key('trend', 1) do
      prev = Trade.with_currency(currency).order('id desc').limit(1).offset(1).first.try(:price)
      last = Trade.with_currency(currency).h24.order('id desc').first.try(:price)

      if prev.nil?
        @trend = 'up'
      elsif last.nil?
        @trend = 'same'
      elsif last  > prev
        @trend = 'up'
      elsif last < prev
        @trend = 'down'
      else
        @trend = 'same'
      end
    end
  end

  def h24_change
    Rails.cache.fetch key('h24_change', 5) do
      old_price = Trade.with_currency(currency).where("created_at < ?", 24.to_i.hours.ago).order('id desc').first.try(:price) || ::Trade::ZERO
      new_price = Trade.with_currency(currency).order('id desc').first.try(:price) || ::Trade::ZERO

      if old_price == 0 || old_price.nil?
        @h24_change = 1 - 1
      else
        (new_price - old_price) / old_price * 100 rescue 0
      end
    end
  end

  def change_trend
    if h24_change > 0
      @change_trend = 'up'
    elsif h24_change < 0
      @change_trend = 'down'
    else
      @change_trend = 'same'
    end
  end

  def h24_volume
    Rails.cache.fetch key('h24_volume', 5) do
      Trade.with_currency(currency).h24.sum(:volume) || ZERO
    end
  end

  def h24_volume_btc
    Rails.cache.fetch key('h24_volume_btc', 5) do
      Trade.with_currency(currency).h24.sum(:funds) || ZERO
    end
  end

  def trades
    Rails.cache.read("peatio:#{currency}:trades") || []
  end

  def since_trades(id)
    trades ||= Trade.with_currency(currency).where("id > ?", id).order(:id).limit(LIMIT)
    trades.map(&:for_global)
  end

  def ohlcs
    Rails.cache.fetch key('ohlc') do
       @ohlc = Ohlc.with_currency(3).order(:mydate).reverse_order.limit(10000)
#      @ohlc = Ohlc.where("currency = ?", 3).order(:mydate).reverse_order.limit(10000)
       @ohlc.map(&:for_global)
    end
  end

  def price
    Rails.cache.fetch key('price', 300) do
      Trade.with_currency(currency)
        .select("id, price, sum(volume) as volume, trend, currency, max(created_at) as created_at")
        .where("created_at > ?", 24.to_i.hours.ago).order(:id)
        .group("ROUND(UNIX_TIMESTAMP(created_at)/(5 * 60))") # group by 5 minutes
        .order('max(created_at) ASC')
        .map(&:for_global)
    end
  end

  def trigger_ticker
    data = {ticker: ticker, asks: asks, bids: bids}
    Pusher.trigger_async(channel, "update", data)
  end

  def trigger_trades(trades)
    Pusher.trigger_async(channel, "trades", trades: trades)
  end

  def at
    @at ||= DateTime.now.to_i
  end
end
