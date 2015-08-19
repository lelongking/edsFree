scope = logics.basicReport

lemon.defineApp Template.basicReport,
  created: ->
    option = {name: 'revenueBasicArea',template: 'revenueBasicAreaReport', data: {}}
    Session.set("basicReportDynamics", option)

  helpers:
    basicReportDynamics: -> Session.get("basicReportDynamics")
    optionActiveClass: (templateName)-> 'active' if Session.get("basicReportDynamics").name is templateName

  events:
    "click .revenueBasicArea": ->
      option = {name: 'revenueBasicArea',template: 'revenueBasicAreaReport', data: {}}
      Session.set("basicReportDynamics", option)
    "click .revenueBasicCustomer": ->
      option = {name: 'revenueBasicCustomer',template: 'revenueBasicCustomerReport', data: {}}
      Session.set("basicReportDynamics", option)
    "click .revenueBasicStaff": ->
      option = {name: 'revenueBasicStaff',template: 'revenueBasicStaffReport', data: {}}
      Session.set("basicReportDynamics", option)

    "click .revenueOfArea": ->
      option = {name: 'revenueOfArea',template: 'revenueOfAreaReport', data: Schema.customerGroups.findOne({totalCash: {$gt: 0}})}
      Session.set("basicReportDynamics", option)
    "click .revenueOfCustomer": ->
      option = {name: 'revenueOfCustomer',template: 'productOfCustomerReport', data: Schema.customers.findOne({debtCash: {$gt: 0}})}
      Session.set("basicReportDynamics", option)
    "click .revenueOfStaff": ->
      option = {name: 'revenueOfStaff',template: 'revenueOfStaffReport', data: {}}
      Session.set("basicReportDynamics", option)
