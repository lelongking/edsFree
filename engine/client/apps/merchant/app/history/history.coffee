scope = logics.basicHistory

lemon.defineApp Template.basicHistory,
  created: ->
    option = {name: 'synthesisDebts',template: 'historySynthesisDebts', data: {}}
    Session.set("basicHistoryDynamics", option)

  helpers:
    basicHistoryDynamics: -> Session.get("basicHistoryDynamics")
    optionActiveClass: (templateName)-> 'active' if Session.get("basicHistoryDynamics").name is templateName

  events:
    "click .revenueBasicArea": ->
      option = {name: 'revenueBasicArea',template: 'revenueBasicAreaReport', data: {}}
      Session.set("basicHistoryDynamics", option)
    "click .revenueBasicCustomer": ->
      option = {name: 'revenueBasicCustomer',template: 'revenueBasicCustomerReport', data: {}}
      Session.set("basicHistoryDynamics", option)
    "click .revenueBasicStaff": ->
      option = {name: 'revenueBasicStaff',template: 'revenueBasicStaffReport', data: {}}
      Session.set("basicHistoryDynamics", option)

    "click .revenueOfArea": ->
      option = {name: 'revenueOfArea',template: 'revenueOfAreaReport', data: Schema.customerGroups.findOne({totalCash: {$gt: 0}})}
      Session.set("basicHistoryDynamics", option)
    "click .revenueOfCustomer": ->
      option = {name: 'revenueOfCustomer',template: 'productOfCustomerReport', data: Schema.customers.findOne({debtCash: {$gt: 0}})}
      Session.set("basicHistoryDynamics", option)
    "click .revenueOfStaff": ->
      option = {name: 'revenueOfStaff',template: 'revenueOfStaffReport', data: {}}
      Session.set("basicHistoryDynamics", option)
