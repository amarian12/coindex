json.deposits @deposits do |deposit|
  json.type 'deposit'
  json.timestamp deposit.created_at.to_i
  if deposit.currency_obj.coin?
    json.coin_amount deposit.amount
    json.coin_currency deposit.currency
  else
    json.fiat_amount deposit.amount
    json.fiat_currency deposit.currency
  end
  json.coin_price ''
  json.fee deposit.fee
end

json.withdraws @withdraws do |withdraw|
  json.type 'withdraw'
  json.timestamp withdraw.created_at.to_i
  if withdraw.coin?
    json.coin_amount withdraw.amount
    json.coin_currency withdraw.currency
  else
    json.fiat_amount withdraw.amount
    json.fiat_currency withdraw.currency
  end
  json.coin_price ''
  json.fee withdraw.fee
end

json.buys @buys do |buy|
  json.type 'buy'
  json.timestamp buy.created_at.to_i
  json.fiat_currency buy.market.quote_unit
  json.fiat_amount buy.volume * buy.price
  json.coin_currency buy.market.base_unit
  json.coin_amount buy.volume
  json.coin_price buy.price
  json.fee ''
end

json.sells @sells do |sell|
  json.type 'sell'
  json.timestamp sell.created_at.to_i
  json.fiat_currency sell.market.quote_unit
  json.fiat_amount sell.volume * sell.price
  json.coin_currency sell.market.base_unit
  json.coin_amount sell.volume
  json.coin_price sell.price
  json.fee ''
end

json.i18n do
  json.sell I18n.t('private.history.account.sell')
  json.buy I18n.t('private.history.account.buy')
  json.deposit I18n.t('header.deposit')
  json.withdraw I18n.t('header.withdraw')
  json.chf I18n.t('currency.name.chf')
  json.btc I18n.t('currency.name.btc')
  json.ltc I18n.t('currency.name.ltc')
  json.via I18n.t('currency.name.via')
  json.drk I18n.t('currency.name.drk')
  json.ppc I18n.t('currency.name.ppc')
  json.btcd I18n.t('currency.name.btcd')
  json.doge I18n.t('currency.name.doge')
  json.nmc I18n.t('currency.name.nmc')
  json.uro I18n.t('currency.name.uro')
  json.lts I18n.t('currency.name.lts')
  json.sys I18n.t('currency.name.sys')
  json.pts I18n.t('currency.name.pts')
end
