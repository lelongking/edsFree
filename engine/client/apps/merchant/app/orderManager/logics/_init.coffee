logics.orderManager = { name: 'sale-logics' }
Apps.Merchant.orderManagerInit = []
Apps.Merchant.orderManagerReactiveRun = []

Apps.Merchant.orderManagerInit.push (scope) ->


Apps.Merchant.orderManagerReactiveRun.push (scope) ->
  if Session.get('mySession')
    scope.currentOrderBill = Schema.orders.findOne Session.get('mySession').currentOrderBill
    Session.set 'currentOrderBill', scope.currentOrderBill

#  if newBuyerId = Session.get('currentOrder')?.buyer
#    if !(oldBuyerId = Session.get('currentBuyer')?._id) or oldBuyerId isnt newBuyerId
#      Session.set('currentBuyer', Schema.customers.findOne newBuyerId)
#  else
#    Session.set 'currentBuyer'