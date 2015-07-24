lemon.defineApp Template.salesNavigationPartial,
  events:
    "click .saleToCustomer": (event, template) -> Router.go('/customer') if Meteor.userId()
    "click .saleToProduct": (event, template) -> Router.go('/product') if Meteor.userId()
    "click .saleToReturn": (event, template) -> Router.go('/customerReturn') if Meteor.userId()

