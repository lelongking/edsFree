scope = logics.customerReturn

customerReturnRoute =
  template: 'customerReturn',
#  waitOnDependency: 'merchantEssential'
  onBeforeAction: ->
    if @ready()
      Apps.setup(scope, Apps.Merchant.customerReturnInit, 'customerReturn')
      Session.set "currentAppInfo",
        name: "trả hàng"
      @next()
  data: ->
    Apps.setup(scope, Apps.Merchant.customerReturnReactiveRun)

    return {
      tabCustomerReturnOptions : scope.tabCustomerReturnOptions
      customerSelectOptions    : scope.customerSelectOptions
      orderSelectOptions       : scope.orderSelectOptions
      allReturnProduct         : scope.managedReturnProductList
    }

lemon.addRoute [customerReturnRoute], Apps.Merchant.RouterBase