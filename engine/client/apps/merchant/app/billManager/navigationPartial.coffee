lemon.defineApp Template.billManagerNavigationPartial,
  events:
    "click .clearBillHistory": (event, template) ->
      currentAppInfo = Session.get("currentAppInfo")
      currentAppInfo.name = 'quản lý phiếu bán'
      Session.set("currentAppInfo", currentAppInfo)
      Session.set("currentBillHistory")
      Session.set("editingId")


