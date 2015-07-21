orderManagerRoute =
  template: 'orderManager'
  onBeforeAction: ->
    if @ready()
      Apps.setup(logics.orderManager, Apps.Merchant.orderManagerInit, 'orderManager')
      @next()
  data: ->
    logics.orderManager.reactiveRun()

    return {
      gridOptions: logics.orderManager.gridOptions
      currentSale: Session.get('currentBillManagerSale')
      currentSaleDetails: logics.orderManager.currentSaleDetails
    }

lemon.addRoute [orderManagerRoute], Apps.Merchant.RouterBase