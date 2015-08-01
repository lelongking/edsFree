lemon.defineWidget Template.customerManagementSaleDetails,
  helpers:
    allowDelete: -> @_id is Template.parentData().transaction

  events:
    "click .deleteTransaction": (event, template) -> Meteor.call 'deleteTransaction', @_id