scope = logics.sales

saleRoute =
  template: 'sales',
#  waitOnDependency: 'merchantEssential'
  onBeforeAction: ->
    if @ready()
      Apps.setup(scope, Apps.Merchant.salesInit, 'sales')
      Session.set "currentAppInfo",
        name: "bán hàng"
        navigationPartial:
          template: "salesNavigationPartial"
          data: {}
      @next()
  data: ->
    Apps.setup(scope, Apps.Merchant.salesReactiveRun)

    return {
      currentOrder                 : Session.get('currentOrder')
      tabOptions                   : scope.tabOptions
      depositOptions               : scope.depositOptions
      debtDateOptions              : scope.debtDateOptions
      discountOptions              : scope.discountOptions
      customerSelectOptions        : scope.customerSelectOptions
      paymentsDeliverySelectOption : scope.paymentsDeliverySelectOptions
      paymentMethodSelectOption    : scope.paymentMethodSelectOptions
    }

lemon.addRoute [saleRoute], Apps.Merchant.RouterBase