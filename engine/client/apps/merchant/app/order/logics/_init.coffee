logics.sales = { name: 'sale-logics' }
Apps.Merchant.salesInit = []
Apps.Merchant.salesReactiveRun = []

Apps.Merchant.salesInit.push (scope) ->
  scope.tabOptions =
    source: Schema.orders.find({orderType: 0})
    currentSource: 'currentOrder'
    caption: 'orderName'
    key: '_id'
    createAction  : -> Order.insert()
    destroyAction : (instance) -> if instance then instance.remove(); Order.findNotSubmitted().count() else -1
    navigateAction: (instance) -> Order.setSession(instance._id)



Apps.Merchant.salesReactiveRun.push (scope) ->
  if Session.get('mySession')
    scope.currentOrder = Schema.orders.findOne Session.get('mySession').currentOrder
    Session.set 'currentOrder', scope.currentOrder

  if newBuyerId = Session.get('currentOrder')?.buyer
    if !(oldBuyerId = Session.get('currentBuyer')?._id) or oldBuyerId isnt newBuyerId
      Session.set('currentBuyer', Schema.customers.findOne newBuyerId)
  else
    Session.set 'currentBuyer'