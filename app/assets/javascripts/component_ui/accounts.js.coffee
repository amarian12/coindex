window.AccountsUI = flight.component ->
  @defaultAttrs
    table: 'tbody'
    filter: '.dropdown-menu a'
    total_btc: '.total_btc .value'

  @refresh = (data) ->
    $table = @select('table')
    $table.prepend(JST['account'](account)) for account in data.accounts
    @select('total_btc').text(fixAsk data.total_btc)

  @filter = (event) ->
    type = event.target.className
    return @list.filter() if type == ''

    @list.filter (item) ->
      item.values().type == "#{gon.i18n[type]}"

  @initList = ->
    options =
      valueNames: [ 'code', 'currency', 'available', 'locked', 'total', 'est_btc']
    @list = new List('accounts', options)

  @after 'initialize', ->
    # accounts = gon.accounts

    $.ajax
      url: "/api/v2/tickers"
      success: (data, status, XHR) ->
        handleData data
        return

    handleData = (data) =>
      accounts = gon.accounts
      
      accounts1 = []
      accounts.forEach (p) ->
        accounts1[p.code] = p
        return

      accounts2 = []

      for own cur of data
        ticker = data[cur].ticker
        item = {}
        [
          # "change"
          "last"
        ].forEach (key) ->
          item[key] = ticker[key]
          return

        item.currency = cur.substring(3)
        accounts2.push item
             
      accounts2.forEach (p) ->
        for a of p
          accounts1[p.currency][a] = p[a]
          return      
      
      i = 0
      total = BigNumber(0)
      while i < accounts.length
        accounts[i].est_btc = accounts[i].last * (BigNumber(accounts[i].available).plus(accounts[i].locked))
        if isNaN parseFloat(accounts[i].est_btc) 
          accounts[i].est_btc = BigNumber(accounts[i].available).plus(accounts[i].locked)
        accounts[i].total = BigNumber(accounts[i].available).plus(accounts[i].locked)
        total = total.plus(accounts[i].est_btc)
        i++

      #console.log total

      total_btc =  BigNumber(total)
      # total_btc =  total

      accounts.sort (a, b)->
        # a.currency < b.currency
        b.currency.localeCompare(a.currency)

      # console.log accounts

      @refresh {accounts: accounts, total_btc: total_btc}
   
      @initList()

      @on @select('filter'), 'click', @filter


