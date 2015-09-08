scope = logics.providerReturn

providerReturnRoute =
  template: 'providerReturn',
#  waitOnDependency: 'merchantEssential'
  onBeforeAction: ->
    if @ready()
      Apps.setup(scope, Apps.Merchant.providerReturnInit, 'providerReturn')
      Session.set "currentAppInfo",
        name: "trả hàng NCC"
        navigationPartial:
          template: "providerReturnNavigationPartial"
          data: {}
      @next()
  data: ->
    Apps.setup(scope, Apps.Merchant.providerReturnReactiveRun)

    return {
      tabProviderReturnOptions : scope.tabProviderReturnOptions
      providerSelectOptions    : scope.providerSelectOptions
      importSelectOptions      : scope.importSelectOptions
    }

lemon.addRoute [providerReturnRoute], Apps.Merchant.RouterBase