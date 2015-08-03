Enums = Apps.Merchant.Enums
Apps.Merchant.customerReturnInit.push (scope) ->
  scope.tabCustomerReturnOptions =
    source: Return.findNotSubmitOf('customer')
    currentSource: 'currentCustomerReturn'
    caption: 'returnName'
    key: '_id'
    createAction  : -> Return.insert('customer')
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
    changeAction: (e) -> scope.currentCustomerReturn.changeOwner(e.added._id)
    reactiveValueGetter: -> Session.get('currentCustomerReturn')?.owner ? 'skyReset'

  scope.orderSelectOptions =
    query: (query) -> query.callback
      results: orderSearch(query)
      text: 'name'
    initSelection: (element, callback) -> callback Schema.orders.findOne(scope.currentCustomerReturn.owner)
    formatSelection: formatCustomerSearch
    formatResult: formatCustomerSearch
    id: '_id'
    placeholder: 'CHỌN PHIẾU BÁN'
    readonly: -> true
    changeAction: (e) -> scope.currentCustomerReturn.changeOwner(e.added._id)
    reactiveValueGetter: -> Session.get('currentCustomerReturn')?.owner ? 'skyReset'

customerSearch = (query) ->
  CustomerSearch.search(query.term); CustomerSearch.getData({sort: {name: 1}})

orderSearch = (query) ->
  CustomerSearch.search(query.term); CustomerSearch.getData({sort: {name: 1}})


formatCustomerSearch = (item) ->
  if item
    name = "#{item.name} "; desc = if item.description then "(#{item.description})" else ""
    name + desc
