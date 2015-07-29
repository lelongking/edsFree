lemon.defineHyper Template.customerNotOfStaffSection,
  helpers:
    customerLists: -> Schema.customers.find({staff: {$exists: false}})
    selected: -> if _.contains(Session.get("staffManagementCustomerListNotOfStaffSelect"), @_id) then 'selected' else ''

  events:
    "click .detail-row:not(.selected) td.command": (event, template) ->
      list = Session.get('staffManagementCustomerListNotOfStaffSelect')
      list.push(@_id)
      Session.set('staffManagementCustomerListNotOfStaffSelect', list)
      event.stopPropagation()

    "click .detail-row.selected td.command": (event, template) ->
      list = Session.get('staffManagementCustomerListNotOfStaffSelect')
      list = _.without(list, @_id)
      Session.set('staffManagementCustomerListNotOfStaffSelect', list)
      event.stopPropagation()