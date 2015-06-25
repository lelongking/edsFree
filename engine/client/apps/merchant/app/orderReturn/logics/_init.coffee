logics.customerReturn = {}
Apps.Merchant.customerReturnInit = []
Apps.Merchant.customerReturnReactiveRun = []

Apps.Merchant.customerReturnReactiveRun.push (scope) ->
  if Session.get('mySession')
    console.log Session.get('mySession').currentCustomerReturn
    scope.currentCustomerReturn = Schema.returns.findOne Session.get('mySession').currentCustomerReturn
    Session.set 'currentCustomerReturn', scope.currentCustomerReturn

#  if newOwnerId = Session.get('currentCustomerReturn')?.owner
#    if !(oldOwnerId = Session.get('currentOwner')?._id) or oldOwnerId isnt newOwnerId
#      Session.set('currentCustomerReturn', Schema.returns.findOne newOwnerId)
#  else
#    Session.set 'currentCustomerReturn'

Apps.Merchant.customerReturnInit.push (scope) ->
  scope.tabOptions =
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
    placeholder: 'CHỌN NGƯỜI MUA'
    changeAction: (e) -> scope.currentCustomerReturn.changeOwner(e.added._id)
    reactiveValueGetter: -> Session.get('currentCustomerReturn')?.owner ? 'skyReset'

customerSearch       = (query) -> CustomerSearch.search(query.term); CustomerSearch.getData({sort: {name: 1}})
formatCustomerSearch = (item) ->
  if item
    name = "#{item.name} "; desc = if item.description then "(#{item.description})" else ""
    name + desc
