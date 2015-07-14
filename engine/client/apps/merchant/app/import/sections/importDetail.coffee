setTime = -> Session.set('realtime-now', new Date())
scope = logics.import

lemon.defineHyper Template.importDetailSection,
  helpers:
    showProductionDate: -> if @productionDate then true else false
    showExpireDate: -> if @expire then true else false
    showDelete: -> !Session.get("currentImport")?.submitted

    oldDebt: -> Session.get('currentProvider')?.totalCash ? 0
    finalDebt: -> Session.get('currentProvider').totalCash + Session.get("currentImport").finalPrice - Session.get("currentImport").depositCash

  created  : ->
    @timeInterval = Meteor.setInterval(setTime, 1000)
  destroyed: ->
    Meteor.clearInterval(@timeInterval)

  events:
    "click .detail-row": (event, template) -> Session.set("editingId", @_id); event.stopPropagation()
    "keyup": (event, template) -> Session.set("editingId") if event.which is 27
    "click .deleteImportDetail": (event, template) -> scope.currentImport.removeImportDetail(@_id)
    "keyup [name='importDescription']": (event, template)->
      Helpers.deferredAction ->
        if currentImport = Session.get('currentImport')
          description = template.ui.$importDescription.val()
          scope.currentImport.changeField('description', description)
      , "currentImportUpdateDescription", 1000


