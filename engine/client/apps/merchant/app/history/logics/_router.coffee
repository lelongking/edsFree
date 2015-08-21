scope = logics.basicHistory
lemon.addRoute
  template: 'basicHistory'
  onBeforeAction: ->
    if @ready()
      Apps.setup(scope, Apps.Merchant.basicHistoryInit, 'basicHistory')
      Session.set "currentAppInfo",
        name: "báo cáo"
      @next()
  data: ->
    Apps.setup(scope, Apps.Merchant.basicHistoryReactive)
, Apps.Merchant.RouterBase