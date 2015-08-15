scope = logics.basicReport
lemon.addRoute
  template: 'basicReport'
  onBeforeAction: ->
    if @ready()
      Apps.setup(scope, Apps.Merchant.basicReportInit, 'basicReport')
      Session.set "currentAppInfo",
        name: "báo cáo"
      @next()
  data: ->
    Apps.setup(scope, Apps.Merchant.basicReportReactive)
, Apps.Merchant.RouterBase