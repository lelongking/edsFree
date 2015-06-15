scope = logics.providerManagement
lemon.addRoute
  part: 'provider'
  template: 'providerManagement'
#  waitOnDependency: 'merchantEssential'
  onBeforeAction: ->
    if @ready()
      Apps.setup(scope, Apps.Merchant.providerManagementInit, 'providerManagement')
      Session.set "currentAppInfo",
        name: "nhà cung cấp"
        navigationPartial:
          template: "providerManagementNavigationPartial"
          data: {}
      @next()
  data: ->
    Apps.setup(scope, Apps.Merchant.providerManagementReactive)

    return {
#      managedProviderList : scope.managedProviderList
#      managedReturnProductList : scope.managedReturnProductList
#      allowCreateProvider : scope.allowCreateProvider
    }
, Apps.Merchant.RouterBase
