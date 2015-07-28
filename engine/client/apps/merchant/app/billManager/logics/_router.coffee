scope = logics.billManager

billManagerRoute =
  template: 'billManager'
  onBeforeAction: ->
    if @ready()
      Apps.setup(scope, Apps.Merchant.billManagerInit, 'billManager')
      Session.set "currentAppInfo",
        name: "tình trạng phiếu bán"
#        navigationPartial:
#          template: "billManagerNavigationPartial"
#          data: {}
      @next()
  data: ->
    Apps.setup(scope, Apps.Merchant.billManagerReactiveRun)

lemon.addRoute [billManagerRoute], Apps.Merchant.RouterBase