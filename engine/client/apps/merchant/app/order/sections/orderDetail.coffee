setTime = -> Session.set('realtime-now', new Date())
scope = logics.sales

lemon.defineHyper Template.saleDetailSection,
  buyer: -> Session.get('currentBuyer')
  billNo: -> Helpers.orderCodeCreate(Session.get('currentBuyer')?.billNo ? '0000')
  sellerName: -> Schema.userProfiles.findOne({user: Session.get("currentOrder")?.seller})?.fullName

  isRowEditing: -> Session.get("editingId") is @_id
  detailFinalPrice: -> @quality * @price - @discountCash
  customerOldDebt: -> if customer = Session.get('currentBuyer') then customer.saleDebt + customer.customSaleDebt else 0
  customerFinalDebt: ->
    if customer = Session.get('currentBuyer') and @profiles
      customer.saleDebt + customer.customSaleDebt + @profiles.finalPrice - @profiles.depositCash
    else 0

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


