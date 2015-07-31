scope = logics.turnoverStaff
lemon.addRoute
  template: 'turnoverStaff'
  onBeforeAction: ->
    if @ready()
      Apps.setup(scope, Apps.Merchant.turnoverStaffInit, 'turnoverStaff')
      Session.set "currentAppInfo",
        name: "doanh số"
      @next()
  data: ->
    Apps.setup(scope, Apps.Merchant.turnoverStaffReactive)

, Apps.Merchant.RouterBase
