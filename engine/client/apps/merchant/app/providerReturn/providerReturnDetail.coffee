scope = logics.providerReturn

lemon.defineHyper Template.providerReturnDetailSection,
#  helpers:
  created: ->
  destroyed: ->

  events:
    "keyup": (event, template) -> Session.set("editingId") if event.which is 27

    "click .detail-row": -> Session.set("editingId", @_id); event.stopPropagation()

    "click .deleteReturnDetail": (event, template) -> scope.currentProviderReturn.removeReturnDetail(@_id)

    "keyup [name='returnDescription']": (event, template)->
      Helpers.deferredAction ->
        if Session.get('currentProviderReturn')
          description = template.ui.$returnDescription.val()
          scope.currentProviderReturn.changeDescription(description)
      , "currentReturnUpdateDescription", 1000