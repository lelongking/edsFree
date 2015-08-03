scope = logics.import

importRoute =
  template: 'import',
#  waitOnDependency: 'merchantEssential'
  onBeforeAction: ->
    if @ready()
      Router.go('/merchant') unless User.hasManagerRoles()
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
      debtDateOptions       : scope.debtDateOptions
    }

lemon.addRoute [importRoute], Apps.Merchant.RouterBase