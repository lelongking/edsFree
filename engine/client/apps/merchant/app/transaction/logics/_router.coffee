scope = logics.transaction
lemon.addRoute
  template: 'transaction'
  onBeforeAction: ->
    if @ready()
      Apps.setup(scope, Apps.Merchant.transactionInit, 'transaction')
      Session.set "currentAppInfo",
        name: "thu chi - tài chính"
      @next()
  data: ->
    Apps.setup(scope, Apps.Merchant.transactionReactive)
    return {
    transactionMenus: scope.transactionMenus
    }

, Apps.Merchant.RouterBase
