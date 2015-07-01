scope = logics.customerGroup
lemon.addRoute
  template: 'customerGroup'
  onBeforeAction: ->
    if @ready()
      Apps.setup(scope, Apps.Merchant.customerGroupInit, 'customerGroup')
      Session.set "currentAppInfo",
        name: "nhóm khách hàng"
#        navigationPartial:
#          template: "customerGroupNavigationPartial"
#          data: {}
      @next()
  data: ->
    Apps.setup(scope, Apps.Merchant.customerGroupReactive)
, Apps.Merchant.RouterBase