scope = logics.warehouse
lemon.addRoute
  template: 'warehouse'
  onBeforeAction: ->
    if @ready()
      Apps.setup(scope, Apps.Merchant.warehouseInit, 'warehouse')
      Session.set "currentAppInfo",
        name: 'quản lý kho hàng'
        navigationPartial:
          template: "warehouseNavigationPartial"
          data: {}
      @next()
  data: ->
    Apps.setup(scope, Apps.Merchant.warehouseReactive)
, Apps.Merchant.RouterBase
