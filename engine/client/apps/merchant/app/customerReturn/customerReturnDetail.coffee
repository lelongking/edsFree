scope = logics.customerReturn

lemon.defineHyper Template.customerReturnDetailSection,
#  helpers:
  created: ->
  destroyed: ->

  events:
    "keyup": (event, template) -> Session.set("editingId") if event.which is 27

    "click .detail-row": -> Session.set("editingId", @_id); event.stopPropagation()

    "click .deleteReturnDetail": (event, template) -> scope.currentCustomerReturn.removeReturnDetail(@_id)

    "keyup [name='returnDescription']": (event, template)->
      Helpers.deferredAction ->
        if Session.get('currentCustomerReturn')
          description = template.ui.$returnDescription.val()
          scope.currentCustomerReturn.changeDescription(description)
      , "currentReturnUpdateDescription", 1000