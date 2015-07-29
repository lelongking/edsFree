lemon.defineHyper Template.customerOfStaffSection,
  helpers:
    customerLists: -> Schema.customers.find({staff: @_id})
    selected: -> if _.contains(Session.get("customerOfStaffSelectLists"), @_id) then 'selected' else ''

  events:
    "click .detail-row:not(.selected) td.command": (event, template) ->
      if userId = Meteor.userId()
        userUpdate = $addToSet:{}; userUpdate.$addToSet["sessions.customerOfStaffSelected.#{Session.get("mySession").currentStaff}"] = @_id
        Meteor.users.update(userId, userUpdate)
      event.stopPropagation()

    "click .detail-row.selected td.command": (event, template) ->
      if userId = Meteor.userId()
        userUpdate = $pull:{}; userUpdate.$pull["sessions.customerOfStaffSelected.#{Session.get("mySession").currentStaff}"] = @_id
        Meteor.users.update(userId, userUpdate)
      event.stopPropagation()