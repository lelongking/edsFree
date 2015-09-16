setTime = -> Session.set('realtime-now', new Date())
scope = logics.sales

lemon.defineHyper Template.saleDetailSection,
  helpers:
    buyer: -> Session.get('currentBuyer')
    billNo: ->
      customerBillNo = Helpers.orderCodeCreate(Session.get('currentBuyer')?.saleBillNo ? '00')
      merchantBillNo = Helpers.orderCodeCreate(Session.get('merchant')?.saleBillNo ? '00')
      customerBillNo + '/' + merchantBillNo

    customerOldDebt: -> if customer = Session.get('currentBuyer') then customer.totalCash else 0

    dueDate: ->
      if order = Session.get("currentOrder")
        moment().add(order.dueDay, 'days').endOf('day').format("DD/MM/YYYY")

    customerFinalDebt: ->
      if order = Session.get("currentOrder")
        if customer = Session.get('currentBuyer')
          customer.totalCash + order.finalPrice - order.depositCash
        else
          order.finalPrice - order.depositCash
      else 0

    details: ->
      console.log 'reCalculate'
      return [] if !@details
      isDisabled = true; isDisabled = if @details?.length > 0 then false else true

      productList = _.groupBy(@details, (item, index) -> item.index = index; item.product)

      for key, value of productList
        if product = Schema.products.findOne(key)
          availableQuantity = product.quantities[0].availableQuantity ? 0
          (saleQuantity  = 0 unless saleQuantity; saleQuantity += item.basicQuantity) for item in value

          for detail in value
            item = @details[detail.index]
            item.productName = product.name
            item.basicName   = product.unitName()

            if product = Schema.products.findOne(item.product)
              item.productName = product.name
              item.basicName   = product.unitName()

              for unit in product.units
                item.basicName  = unit.name if item.isBase
                if unit._id is item.productUnit
                  item.unitName   = unit.name
                  item.isBase     = unit.isBase
                  item.conversion = unit.conversion
                  item.finalPrice = item.quality * item.conversion * (item.price - item.discountCash)
                  if product.inventoryInitial
                    crossAvailable = Math.floor((availableQuantity - saleQuantity)/item.conversion)
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
            (isDisabled = Session.get("currentOrder").buyer is undefined) unless isDisabled
      Session.set('currentOrderIsDisabled', if isDisabled then 'disabled' else '')

      @details

  created   : -> @timeInterval = Meteor.setInterval(setTime, 1000)
  destroyed : -> Meteor.clearInterval(@timeInterval)

  events:
    "click .detail-row": (event, template) -> Session.set("editingId", @_id); event.stopPropagation()
    "keyup": (event, template) -> Session.set("editingId") if event.which is 27
    "click .deleteOrderDetail": (event, template) -> scope.currentOrder.removeDetail(@_id)
    "input [name='orderDescription']": (event, template) ->
      Helpers.deferredAction ->
        description = template.ui.$orderDescription.val()
        scope.currentOrder.changeDescription(description)
      , "currentSaleUpdateDescription", 1000


