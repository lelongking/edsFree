setTime = -> Session.set('realtime-now', new Date())
scope = logics.sales

lemon.defineHyper Template.providerReturnHistoryDetailSection,
  helpers:
    buyer: -> Session.get('currentBuyer')

    details: ->
      return [] unless @details
      isDisabled = true; isDisabled = if @details.length > 0 then false else true
      for item in @details
        if product = Schema.products.findOne(item.product)
          item.productName = product.name
          item.basicName   = product.unitName()

          for unit in product.units
            item.basicName  = unit.name if item.isBase
            if unit._id is item.productUnit
              item.unitName   = unit.name
              item.isBase     = unit.isBase
              item.conversion = unit.conversion
              item.finalPrice = item.quality * (item.price - item.discountCash)
      @details

  created   : -> @timeInterval = Meteor.setInterval(setTime, 1000)
  destroyed : -> Meteor.clearInterval(@timeInterval)

#  events:
#    "click .detail-row": (event, template) -> Session.set("editingId", @_id); event.stopPropagation()
#    "keyup": (event, template) -> Session.set("editingId") if event.which is 27
#    "click .deleteOrderDetail": (event, template) -> scope.currentOrder.removeDetail(@_id)
#    "input [name='orderDescription']": (event, template) ->
#      Helpers.deferredAction ->
#        description = template.ui.$orderDescription.val()
#        scope.currentOrder.changeDescription(description)
#      , "currentSaleUpdateDescription", 1000
#
#
