lemon.defineApp Template.productGroupNavigationPartial,
  events:
    "click .productToSales": (event, template) ->
      if product = Session.get("productGroupCurrentProduct")
        Meteor.call 'productToSales', product, Session.get('myProfile'), (error, result) ->
          if error then console.log error else Router.go('/sales')

    "click .productToReturns": (event, template) ->
      if product = Session.get("productGroupCurrentProduct")
        Meteor.call 'productToReturns', product, Session.get('myProfile'), (error, result) ->
          if error then console.log error else Router.go('/productReturn')
