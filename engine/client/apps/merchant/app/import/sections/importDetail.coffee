setTime = -> Session.set('realtime-now', new Date())
scope = logics.import

lemon.defineHyper Template.importDetailSection,
  helpers:
    provider: -> Session.get('currentProvider')
    billNo: -> Helpers.orderCodeCreate(Session.get('currentProvider')?.billNo ? '0000')
    dueDate: -> moment().add(Session.get('currentImport').dueDay, 'days').endOf('day').format("DD/MM/YYYY") if Session.get('currentImport')

    oldDebt: -> if provider = Session.get('currentProvider') then provider.totalCash else 0
    finalDebt: ->
      if currentImport = Session.get("currentImport")
        if provider = Session.get('currentProvider')
          provider.totalCash + currentImport.finalPrice - currentImport.depositCash
        else
          Session.get("currentImport").finalPrice - Session.get("currentImport").depositCash
      else 0

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


