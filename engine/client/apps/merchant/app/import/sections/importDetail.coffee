setTime = -> Session.set('realtime-now', new Date())
scope = logics.import

lemon.defineHyper Template.importDetailSection,
  isRowEditing: -> Session.get("editingId") is @_id

  showProductionDate: -> if @productionDate then true else false
  showExpireDate: -> if @expire then true else false
  showDelete: -> !Session.get("currentImport")?.submitted

  oldDebt: ->
    distributor = Session.get('currentImportDistributor')
    partner = Session.get('currentImportPartner')

    if @import?.distributor and distributor then distributor.importDebt + distributor.customImportDebt
    else if @import?.partner and partner then partner.importCash + partner.loanCash - partner.saleCash - partner.paidCash
    else 0

  finalDebt: ->
    distributor = Session.get('currentImportDistributor')
    partner = Session.get('currentImportPartner')

    if @import?.distributor and distributor
      distributor.importDebt + distributor.customImportDebt + @import.totalPrice - @import.deposit
    else if @import?.partner and partner
      partner.importCash + partner.loanCash - partner.saleCash - partner.paidCash + @import.totalPrice - @import.deposit
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
          scope.currentImport.changeDescription(description)
      , "currentImportUpdateDescription", 1000


