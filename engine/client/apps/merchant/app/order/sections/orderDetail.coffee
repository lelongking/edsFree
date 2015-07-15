setTime = -> Session.set('realtime-now', new Date())
scope = logics.sales

lemon.defineHyper Template.saleDetailSection,
  helpers:
    buyer: -> Session.get('currentBuyer')
    billNo: -> Helpers.orderCodeCreate(Session.get('currentBuyer')?.billNo ? '0000')
    dueDate: -> moment().add(Session.get('currentOrder').dueDay, 'days').endOf('day').format("DD/MM/YYYY")
    customerOldDebt: -> if customer = Session.get('currentBuyer') then customer.debtCash + customer.loanCash else 0
    customerFinalDebt: ->
      order = Session.get("currentOrder")
      if customer = Session.get('currentBuyer')
        customer.debtCash + customer.loanCash + order.finalPrice - order.depositCash
      else
        Session.get("currentOrder").finalPrice - Session.get("currentOrder").depositCash

    details: ->
      for item in @details
        if product = Schema.products.findOne(item.product)
          item.productName = product.name
          item.basicName   = product.unitName()
          for unit in product.units
            if item.isBase
              item.basicName  = unit.name
            else if unit._id is item.productUnit
              item.unitName   = unit.name
              item.isBase     = unit.isBase
              item.conversion = unit.conversion
              item.finalPrice = item.quality * (item.price - item.discountCash)

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


