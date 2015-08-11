#setTime = -> Session.set('realtime-now', new Date())
scope = logics.billDetail
lemon.defineHyper Template.billDetailGridSection,
  helpers:
    buyer: -> Session.get('currentBuyer')
    billNo: -> Helpers.orderCodeCreate(Session.get('currentBuyer')?.billNo ? '0000')

    customerOldDebt: -> if customer = Session.get('currentBuyer') then customer.totalCash else 0
    customerFinalDebt: ->
      if order = Session.get("currentBillHistory")
        if customer = Session.get('currentBuyer')
          customer.totalCash + order.finalPrice - order.depositCash
        else
          order.finalPrice - order.depositCash
      else 0

    details: ->
      return [] unless @details
      isDisabled = true; isDisabled = if @details?.length > 0 then false else true
      for item in @details
        item.model = 'orderDetail'
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
              if product.inventoryInitial
                crossAvailable = (unit.quality.availableQuality - item.basicQuality)/unit.conversion
                item.crossAvailable = crossAvailable
                item.isValid        = crossAvailable > 0
                item.invalid        = crossAvailable < 0
                item.errorClass     = if crossAvailable >= 0 then '' else 'errors'
              else
                item.crossAvailable = 0
                item.isValid        = true
                item.invalid        = false
                item.errorClass     = ''

        if item.invalid then isDisabled = item.invalid
      Session.set('currentBillHistoryIsDisabled', if isDisabled then 'disabled' else '')
      @details

  events:
    "click .detail-row": (event, template) -> Session.set("editingId", @_id); event.stopPropagation()
    "keyup": (event, template) -> Session.set("editingId") if event.which is 27
    "click .deleteOrderDetail": (event, template) -> scope.currentBillHistory.removeDetail(@_id)
    "input [name='orderDescription']": (event, template) ->
      Helpers.deferredAction ->
        description = template.ui.$orderDescription.val()
        scope.currentBillHistory.changeDescription(description)
      , "currentSaleUpdateDescription", 1000
