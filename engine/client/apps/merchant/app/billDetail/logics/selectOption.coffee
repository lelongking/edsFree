Enums = Apps.Merchant.Enums

formatDefaultSearch  = (item) -> "#{item.display}" if item
findPaymentMethods   = (paymentMethodId)-> _.findWhere(Enums.PaymentMethods, {_id: paymentMethodId})
findDeliveryTypes    = (deliveryTypeId)-> _.findWhere(Enums.DeliveryTypes, {_id: deliveryTypeId})
customerSearch       = (query) -> CustomerSearch.search(query.term); CustomerSearch.getData({sort: {name: 1}})
formatCustomerSearch = (item) ->
  if item
    name = "#{item.name} "; desc = if item.description then "(#{item.description})" else ""
    name + desc

Apps.Merchant.billDetailInit.push (scope) ->
  scope.depositOptions =
    reactiveSetter: (val) -> scope.currentBillHistory.changeDepositCash(val)
    reactiveValue: -> Session.get('currentBillHistory')?.depositCash ? 0
    reactiveMax: -> 99999999999
    reactiveMin: -> 0
    reactiveStep: -> 1000
    others:
      forcestepdivisibility: 'none'

  scope.discountOptions =
    reactiveSetter: (val) -> scope.currentBillHistory.changeDiscountCash(val)
    reactiveValue: -> Session.get('currentBillHistory')?.discountCash ? 0
    reactiveMax: -> 99999999999
    reactiveMin: -> 0
    reactiveStep: -> 1000
    others:
      forcestepdivisibility: 'none'

  scope.customerSelectOptions =
    query: (query) -> query.callback
      results: customerSearch(query)
      text: 'name'
    initSelection: (element, callback) -> callback Schema.customers.findOne(scope.currentBillHistory.buyer)
    formatSelection: formatCustomerSearch
    formatResult: formatCustomerSearch
    id: '_id'
    placeholder: 'CHỌN NGƯỜI MUA'
    readonly: -> true
    changeAction: (e) -> scope.currentBillHistory.changeBuyer(e.added._id)
    reactiveValueGetter: -> Session.get('currentBillHistory')?.buyer ? 'skyReset'

  scope.sellerSelectOptions =
    query: (query) -> query.callback
      results: [Meteor.users.findOne(scope.currentBillHistory.seller).profile]
      text: 'name'
    initSelection: (element, callback) -> callback Meteor.users.findOne(scope.currentBillHistory?.seller)?.profile
    formatSelection: formatCustomerSearch
    formatResult: formatCustomerSearch
    id: 'name'
    placeholder: 'CHỌN NGƯỜI MUA'
    readonly: -> true
    changeAction: (e) -> scope.currentBillHistory.changeBuyer(e.added._id)
    reactiveValueGetter: -> Meteor.users.findOne(Session.get('currentBillHistory')?.seller)?.profile ? 'skyReset'

  scope.paymentsDeliverySelectOptions =
    query: (query) -> query.callback
      results: Enums.DeliveryTypes
      text: '_id'
    initSelection: (element, callback) -> callback findDeliveryTypes(Session.get('currentBillHistory')?.paymentsDelivery)
    formatSelection: formatDefaultSearch
    formatResult: formatDefaultSearch
    placeholder: 'CHỌN SẢN PTGD'
    minimumResultsForSearch: -1
    readonly: -> !User.hasManagerRoles()
    changeAction: (e) -> scope.currentBillHistory.changePaymentsDelivery(e.added._id)
    reactiveValueGetter: -> findDeliveryTypes(Session.get('currentBillHistory')?.paymentsDelivery)

  scope.paymentMethodSelectOptions =
    query: (query) -> query.callback
      results: Enums.PaymentMethods
      text: '_id'
    initSelection: (element, callback) -> callback findPaymentMethods(Session.get('currentBillHistory')?.paymentMethod)
    formatSelection: formatDefaultSearch
    formatResult: formatDefaultSearch
    placeholder: 'CHỌN SẢN PTGD'
    minimumResultsForSearch: -1
    readonly: -> !User.hasManagerRoles()
    changeAction: (e) -> scope.currentBillHistory.changePaymentMethod(e.added._id)
    reactiveValueGetter: -> findPaymentMethods(Session.get('currentBillHistory')?.paymentMethod)