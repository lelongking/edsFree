lemon.defineApp Template.customerManagementNavigationPartial,
  events:
    "click .customerOldDebt": (event, template) ->
      oldDebt = Session.get("customerManagementOldDebt")
      if oldDebt is true
        Session.set("customerManagementOldDebt")
      else
        Session.set("customerManagementOldDebt", true)

    "click .customerPaid": (event, template) ->
      oldDebt = Session.get("customerManagementOldDebt")
      if oldDebt is false
        Session.set("customerManagementOldDebt")
      else
        Session.set("customerManagementOldDebt", false)

    "click .customerToSales": (event, template) ->
      if customer = Session.get("customerManagementCurrentCustomer")
        Meteor.call 'customerToOrder', customer._id, (error, result) -> if error then console.log error else Router.go('/sales')

#    "click .customerToReturns": (event, template) ->
#      if customer = Session.get("customerManagementCurrentCustomer")
#        Meteor.call 'customerToReturns', customer, Session.get('myProfile'), (error, result) ->
#          if error then console.log error else Router.go('/customerReturn')
