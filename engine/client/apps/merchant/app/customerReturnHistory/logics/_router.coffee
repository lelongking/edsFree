scope = logics.orderReturnHistory

orderReturnHistoryRoute =
  template: 'orderReturnHistory',
  onBeforeAction: ->
    if @ready()
      Apps.setup(scope, Apps.Merchant.orderReturnHistoryInit, 'orderReturnHistory')
      Session.set "currentAppInfo",
        name: "phiếu trả hàng"
        navigationPartial:
          template: "customerReturnHistoryNavigationPartial"
          data: {}
      @next()
  data: ->
    Apps.setup(scope, Apps.Merchant.orderReturnHistoryReactiveRun)
    return {
    }

lemon.addRoute [orderReturnHistoryRoute], Apps.Merchant.RouterBase