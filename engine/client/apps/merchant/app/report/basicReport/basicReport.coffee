scope = logics.basicReport

lemon.defineApp Template.basicReport,
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
      option = {name: 'revenueOfArea',template: 'revenueOfAreaReport', data: {}}
      Session.set("basicReportDynamics", option)
    "click .revenueOfCustomer": ->
      option = {name: 'revenueOfCustomer',template: 'revenueOfCustomerReport', data: {}}
      Session.set("basicReportDynamics", option)
    "click .revenueOfStaff": ->
      option = {name: 'revenueOfStaff',template: 'revenueOfStaffReport', data: {}}
      Session.set("basicReportDynamics", option)
