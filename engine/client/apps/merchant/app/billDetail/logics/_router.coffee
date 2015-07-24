scope = logics.billDetail

billDetailRoute =
  template: 'billDetail'
  onBeforeAction: ->
    if @ready()
      Apps.setup(scope, Apps.Merchant.billDetailInit, 'billDetail')
      Session.set "currentAppInfo",
        name: "chi tiết phiếu bán"
        navigationPartial:
          template: "billDetailNavigationPartial"
          data: {}
      @next()
  data: ->
    Apps.setup(scope, Apps.Merchant.billDetailReactiveRun)

lemon.addRoute [billDetailRoute], Apps.Merchant.RouterBase