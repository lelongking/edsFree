scope = logics.providerReturnHistory

providerReturnHistoryRoute =
  template: 'providerReturnHistory',
  onBeforeAction: ->
    if @ready()
      Apps.setup(scope, Apps.Merchant.providerReturnHistoryInit, 'providerReturnHistory')
      Session.set "currentAppInfo",
        name: "phiếu trả hàng NCC"
        navigationPartial:
          template: "providerReturnHistoryNavigationPartial"
          data: {}
      @next()
  data: ->
    Apps.setup(scope, Apps.Merchant.providerReturnHistoryReactiveRun)
    return {
    }

lemon.addRoute [providerReturnHistoryRoute], Apps.Merchant.RouterBase