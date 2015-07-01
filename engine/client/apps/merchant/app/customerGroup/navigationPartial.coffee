lemon.defineApp Template.customerGroupNavigationPartial,
  events:
    "click .customerToSales": (event, template) ->
      if customer = Session.get("customerGroupCurrentCustomer")
        Meteor.call 'customerToSales', customer, Session.get('myProfile'), (error, result) ->
          if error then console.log error else Router.go('/sales')

    "click .customerToReturns": (event, template) ->
      if customer = Session.get("customerGroupCurrentCustomer")
        Meteor.call 'customerToReturns', customer, Session.get('myProfile'), (error, result) ->
          if error then console.log error else Router.go('/customerReturn')
