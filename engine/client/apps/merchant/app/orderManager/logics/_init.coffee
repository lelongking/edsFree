logics.orderManager = { name: 'sale-logics' }
Apps.Merchant.orderManagerInit = []
Apps.Merchant.orderManagerReactiveRun = []

Apps.Merchant.orderManagerInit.push (scope) ->


Apps.Merchant.orderManagerReactiveRun.push (scope) ->
  if Session.get('mySession')
    orderQuery = {_id: Session.get('mySession').currentOrderBill}
    orderQuery.seller = Meteor.userId() unless User.hasManagerRoles()
    scope.currentOrderBill = Schema.orders.findOne orderQuery
    Session.set 'currentOrderBill', scope.currentOrderBill

#  if newBuyerId = Session.get('currentOrder')?.buyer
#    if !(oldBuyerId = Session.get('currentBuyer')?._id) or oldBuyerId isnt newBuyerId
#      Session.set('currentBuyer', Schema.customers.findOne newBuyerId)
#  else
#    Session.set 'currentBuyer'