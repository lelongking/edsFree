scope = logics.customerGroup

lemon.defineHyper Template.customerGroupDetailSection,
  helpers:
    selected: -> if _.contains(Session.get("customerSelectLists"), @_id) then 'selected' else ''
    customerLists: ->
      return [] if !@customers or @customers.length is 0
      Schema.customers.find({_id: {$in: @customers}, group: @_id},{sort: {name: 1}})

  rendered: ->

  events:
    "click .detail-row:not(.selected) td.command": (event, template) -> scope.currentCustomerGroup.selectedCustomer(@_id)
    "click .detail-row.selected td.command": (event, template) -> scope.currentCustomerGroup.unSelectedCustomer(@_id)