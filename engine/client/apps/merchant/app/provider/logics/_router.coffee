scope = logics.providerManagement
lemon.addRoute
  part: 'provider'
  template: 'providerManagement'
#  waitOnDependency: 'merchantEssential'
  onBeforeAction: ->
    if @ready()
      Router.go('/merchant') unless User.roleIsManager()
      Apps.setup(scope, Apps.Merchant.providerManagementInit, 'providerManagement')
      Session.set "currentAppInfo",
        name: "nhà cung cấp"
        navigationPartial:
          template: "providerManagementNavigationPartial"
          data: {}
      @next()
  data: ->
    Apps.setup(scope, Apps.Merchant.providerManagementReactive)
, Apps.Merchant.RouterBase
