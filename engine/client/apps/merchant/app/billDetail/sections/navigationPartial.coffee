lemon.defineApp Template.billDetailNavigationPartial,
  events:
    "click .clearBillHistory": (event, template) ->
      Session.set("currentBillHistory")
      Session.set("editingId")
      Router.go 'billManager'