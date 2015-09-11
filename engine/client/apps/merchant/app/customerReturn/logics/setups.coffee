Enums = Apps.Merchant.Enums
Apps.Merchant.customerReturnInit.push (scope) ->
  scope.tabCustomerReturnOptions =
    source: Return.findNotSubmitOf('customer')
    currentSource: 'currentCustomerReturn'
    caption: 'returnName'
    key: '_id'
    createAction  : -> Return.insert(Enums.getValue('OrderTypes', 'customer'))
    destroyAction : (instance) -> if instance then instance.remove(); Return.findNotSubmitOf('customer').count() else -1
    navigateAction: (instance) -> Return.setReturnSession(instance._id, 'customer')

  scope.customerSelectOptions =
    query: (query) -> query.callback
      results: customerSearch(query)
      text: 'name'
    initSelection: (element, callback) -> callback Schema.customers.findOne(scope.currentCustomerReturn.owner)
    formatSelection: formatCustomerSearch
    formatResult: formatCustomerSearch
    id: '_id'
    placeholder: 'CHỌN KHÁCH HÀNG'
    readonly: -> true
    changeAction: (e) -> scope.currentCustomerReturn.selectOwner(e.added._id)
    reactiveValueGetter: -> Session.get('currentCustomerReturn')?.owner ? 'skyReset'

  scope.orderSelectOptions =
    query: (query) -> query.callback
      results: findOrderByCustomer(Session.get('currentCustomerReturn')?.owner)
      text: '_id'
    initSelection: (element, callback) -> callback Schema.orders.findOne(scope.currentCustomerReturn?.parent)
    formatSelection: (item) -> "#{item.orderCode}" if item
    formatResult: (item) -> "#{item.orderCode}" if item
    id: '_id'
    placeholder: 'CHỌN PHIẾU BÁN'
    minimumResultsForSearch: -1
    readonly: -> true
    changeAction: (e) -> scope.currentCustomerReturn.selectParent(e.added._id)
    reactiveValueGetter: -> Session.get('currentCustomerReturn')?.parent ? 'skyReset'

customerSearch = (query) ->
  selector = {merchant: Merchant.getId(), billNo: {$gt: 0}}; options = {sort: {nameSearch: 1}}
  if(query.term)
    regExp = Helpers.BuildRegExp(query.term);
    selector = {$or: [
      {nameSearch: regExp, merchant: Merchant.getId(), billNo: {$gt: 0}}
    ]}
  Schema.customers.find(selector, options).fetch()

findOrderByCustomer = (customerId) ->
  orderLists = []
  if customerId
    orderLists = Schema.orders.find({
      merchant    : Merchant.getId()
      buyer       : customerId
      orderType   : Enums.getValue('OrderTypes', 'success')
      orderStatus : Enums.getValue('OrderStatus', 'finish')
    }).fetch()
  orderLists


formatCustomerSearch = (item) -> item.name if item
#  if item
#    name = "#{item.name} "; desc = if item.description then "(#{item.description})" else ""
#    name + desc
