deliveryRoute =
  template: 'delivery'
  onBeforeAction: ->
    if @ready()
      Apps.setup(logics.delivery, Apps.Merchant.deliveryInit, 'delivery')
      Session.set "currentAppInfo",
        name: "giao hàng"
      @next()
  data: ->
    return {
      waitingGridOptions: logics.delivery.waitingGridOptions
      deliveringGridOptions: logics.delivery.deliveringGridOptions
      doneGridOptions: logics.delivery.doneGridOptions
    }

lemon.addRoute [deliveryRoute], Apps.Merchant.RouterBase