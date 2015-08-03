scope = logics.priceBook
lemon.addRoute
  template: 'priceBook'
#  waitOnDependency: 'merchantEssential'
  onBeforeAction: ->
    if @ready()
      Router.go('/merchant') unless User.hasManagerRoles()
      Apps.setup(scope, Apps.Merchant.priceBookInit, 'priceBook')
      Session.set "currentAppInfo",
        name: "bảng giá"
        navigationPartial:
          template: "priceBookNavigationPartial"
          data: {}
      @next()
  data: ->
    Apps.setup(scope, Apps.Merchant.priceBookReactive)
, Apps.Merchant.RouterBase