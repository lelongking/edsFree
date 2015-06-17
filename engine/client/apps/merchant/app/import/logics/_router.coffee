scope = logics.import

importRoute =
  template: 'import',
#  waitOnDependency: 'merchantEssential'
  onBeforeAction: ->
    if @ready()
      Apps.setup(scope, Apps.Merchant.importInit, 'import')
      Session.set "currentAppInfo",
        name: "nhập kho"
      @next()
  data: ->
    Apps.setup(scope, Apps.Merchant.importReactive)

    return {
      tabOptions            : scope.tabOptions
      currentImport         : Session.get('currentImport')
      providerSelectOptions : scope.providerSelectOptions
      depositOptions        : scope.depositOptions
      discountOptions       : scope.discountOptions
    }

lemon.addRoute [importRoute], Apps.Merchant.RouterBase