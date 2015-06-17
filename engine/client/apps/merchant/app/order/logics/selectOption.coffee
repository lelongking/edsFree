formatDefaultSearch  = (item) -> "#{item.display}" if item
findPaymentMethods   = (paymentMethodId)-> _.findWhere(Apps.Merchant.PaymentMethods, {_id: paymentMethodId})
findDeliveryTypes    = (deliveryTypeId)-> _.findWhere(Apps.Merchant.DeliveryTypes, {_id: deliveryTypeId})
customerSearch       = (query) -> CustomerSearch.search(query.term); CustomerSearch.getData({sort: {name: 1}})
formatCustomerSearch = (item) ->
  if item
    name = "#{item.name} "; desc = if item.description then "(#{item.description})" else ""
    name + desc

Apps.Merchant.salesInit.push (scope) ->
  scope.tabOptions =
    source: Schema.orders.find()
    currentSource: 'currentOrder'
    caption: 'orderName'
    key: '_id'
    createAction  : -> Order.insert()
    destroyAction : (instance) -> if order then Schema.orders.find().count() if order.remove() else -1
    navigateAction: (instance) -> Meteor.users.update(Meteor.userId(), {$set: {'sessions.currentOrder': instance._id}})

  scope.depositOptions =
    reactiveSetter: (val) -> scope.currentOrder.changeDepositCash(val)
    reactiveValue: -> Session.get('currentOrder')?.profiles.depositCash ? 0
    reactiveMax: -> 99999999999
    reactiveMin: -> 0
    reactiveStep: -> 1000
    others:
      forcestepdivisibility: 'none'

  scope.customerSelectOptions =
    query: (query) -> query.callback
      results: customerSearch(query)
      text: 'name'
    initSelection: (element, callback) -> callback Schema.customers.findOne(scope.currentOrder.buyer)
    formatSelection: formatCustomerSearch
    formatResult: formatCustomerSearch
    id: '_id'
    placeholder: 'CHỌN NGƯỜI MUA'
    changeAction: (e) -> scope.currentOrder.changeBuyer(e.added._id)
    reactiveValueGetter: -> Session.get('currentOrder')?.buyer ? 'skyReset'

  scope.paymentsDeliverySelectOptions =
    query: (query) -> query.callback
      results: Apps.Merchant.DeliveryTypes
      text: '_id'
    initSelection: (element, callback) -> callback findDeliveryTypes(Session.get('currentOrder')?.profiles.paymentsDelivery)
    formatSelection: formatDefaultSearch
    formatResult: formatDefaultSearch
    placeholder: 'CHỌN SẢN PTGD'
    minimumResultsForSearch: -1
    changeAction: (e) -> scope.currentOrder.changePaymentsDelivery(e.added._id)
    reactiveValueGetter: -> findDeliveryTypes(Session.get('currentOrder')?.profiles.paymentsDelivery)

  scope.paymentMethodSelectOptions =
    query: (query) -> query.callback
      results: Apps.Merchant.PaymentMethods
      text: '_id'
    initSelection: (element, callback) -> callback findPaymentMethods(Session.get('currentOrder')?.profiles.paymentMethod)
    formatSelection: formatDefaultSearch
    formatResult: formatDefaultSearch
    placeholder: 'CHỌN SẢN PTGD'
    minimumResultsForSearch: -1
    changeAction: (e) -> scope.currentOrder.changePaymentMethod(e.added._id)
    reactiveValueGetter: -> findPaymentMethods(Session.get('currentOrder')?.profiles.paymentMethod)

#---------------------
  logics.sales.createNewOrderAndSelected = ->
    if Session.get('myProfile') and buyer = Schema.customers.findOne(Session.get('currentOrder')?.buyer)
      if newOrder = Order.insert(buyer, Session.get('myProfile'))
        Session.set('currentOrder', newOrder)
    else
      console.log buyer, Session.get('myProfile')
      return undefined
