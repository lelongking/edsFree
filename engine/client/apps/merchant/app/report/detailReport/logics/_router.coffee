scope = logics.merchantReport
lemon.addRoute
  template: 'd'
  onBeforeAction: ->
    if @ready()
      Apps.setup(scope, Apps.Merchant.merchantReportInit, 'merchantReport')
      Session.set "currentAppInfo",
        name: "báo cáo"
      @next()
  data: ->
#    Apps.setup(scope, Apps.Merchant.merchantReportReactive)
    return {
      dayRecords:
        transactions: Schema.transactions.find().fetch()
        sales: Schema.orders.find().fetch()
        imports: Schema.imports.find().fetch()
        returns: Schema.returns.find().fetch()
    }
, Apps.Merchant.RouterBase