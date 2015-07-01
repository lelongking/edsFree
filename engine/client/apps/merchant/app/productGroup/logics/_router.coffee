scope = logics.productGroup
lemon.addRoute
  template: 'productGroup'
  onBeforeAction: ->
    if @ready()
      Apps.setup(scope, Apps.Merchant.productGroupInit, 'productGroup')
      Session.set "currentAppInfo",
        name: "nhóm sản phẩm"
#        navigationPartial:
#          template: "productGroupNavigationPartial"
#          data: {}
      @next()
  data: ->
    Apps.setup(scope, Apps.Merchant.productGroupReactive)
, Apps.Merchant.RouterBase