scope = logics.staffManagement
lemon.addRoute
  path: 'staffs'
  template: 'staffManagement'
  onBeforeAction: ->
    if @ready()
      Router.go('/merchant') unless User.hasAdminRoles()
      Apps.setup(scope, Apps.Merchant.staffManagementInit, 'staffManagement')
      Session.set "currentAppInfo",
        name: "nhân viên"
        navigationPartial:
          template: "staffManagementNavigationPartial"
          data: {}
      @next()
  data: ->
    Apps.setup(scope, Apps.Merchant.staffManagementReactive)

, Apps.Merchant.RouterBase