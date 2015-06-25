scope = logics.customerReturn
setTime = -> Session.set('realtime-now', new Date())

lemon.defineHyper Template.customerReturnDetailSection,
  created: -> @timeInterval = Meteor.setInterval(setTime, 1000)
  destroyed: -> Meteor.clearInterval(@timeInterval)

  events:
    "click .detail-row": -> Session.set("editingId", @_id); event.stopPropagation()
    "keyup": (event, template) -> Session.set("editingId") if event.which is 27
    "click .deleteReturnDetail": (event, template) -> scope.currentCustomerReturn.removeReturnDetail(@_id)
    "keyup [name='returnDescription']": (event, template)->
      Helpers.deferredAction ->
        if Session.get('currentCustomerReturn')
          description = template.ui.$returnDescription.val()
          scope.currentCustomerReturn.changeDescription(description)
      , "currentReturnUpdateDescription", 1000



