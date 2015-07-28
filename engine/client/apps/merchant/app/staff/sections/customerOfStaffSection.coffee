lemon.defineHyper Template.customerOfStaffSection,
  helpers:
    customerLists: -> Schema.customers.find()

  rendered: ->