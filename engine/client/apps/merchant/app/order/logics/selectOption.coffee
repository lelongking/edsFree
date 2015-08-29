Enums = Apps.Merchant.Enums

formatDefaultSearch  = (item) -> "#{item.display}" if item
findPaymentMethods   = (paymentMethodId)-> _.findWhere(Enums.PaymentMethods, {_id: paymentMethodId})
findDeliveryTypes    = (deliveryTypeId)-> _.findWhere(Enums.DeliveryTypes, {_id: deliveryTypeId})
customerSearch       = (query) -> CustomerSearch.search(query.term); CustomerSearch.getData({sort: {name: 1}})
formatCustomerSearch = (item) -> item.name if item
#    name = "#{item.name} "; desc = if item.description then "(#{item.description})" else ""
#    name + desc

Apps.Merchant.salesInit.push (scope) ->
  scope.depositOptions =
    reactiveSetter: (val) -> scope.currentOrder.changeDepositCash(val)
    reactiveValue: -> Session.get('currentOrder')?.depositCash ? 0
    reactiveMax: -> 99999999999
    reactiveMin: -> 0
    reactiveStep: -> 1000
    others:
      forcestepdivisibility: 'none'

  scope.discountOptions =
    reactiveSetter: (val) -> scope.currentOrder.changeDiscountCash(val)
    reactiveValue: -> Session.get('currentOrder')?.discountCash ? 0
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
      results: Enums.DeliveryTypes
      text: '_id'
    initSelection: (element, callback) -> callback findDeliveryTypes(Session.get('currentOrder')?.paymentsDelivery)
    formatSelection: formatDefaultSearch
    formatResult: formatDefaultSearch
    placeholder: 'CHỌN PTGD'
    minimumResultsForSearch: -1
    changeAction: (e) -> scope.currentOrder.changePaymentsDelivery(e.added._id)
    reactiveValueGetter: -> findDeliveryTypes(Session.get('currentOrder')?.paymentsDelivery)

  scope.paymentMethodSelectOptions =
    query: (query) -> query.callback
      results: Enums.PaymentMethods
      text: '_id'
    initSelection: (element, callback) -> callback findPaymentMethods(Session.get('currentOrder')?.paymentMethod)
    formatSelection: formatDefaultSearch
    formatResult: formatDefaultSearch
    placeholder: 'CHỌN PTGD'
    minimumResultsForSearch: -1
    changeAction: (e) -> scope.currentOrder.changePaymentMethod(e.added._id)
    reactiveValueGetter: -> findPaymentMethods(Session.get('currentOrder')?.paymentMethod)