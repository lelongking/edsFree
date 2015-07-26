findPriceBookTypes   = (priceBookTypeId)-> _.findWhere(Apps.Merchant.PriceBookTypes, {_id: priceBookTypeId})
priceBookOwnerSearch  = (query) ->
  if Session.get("currentPriceBook").priceBookType is 0
    [{_id: 0, name: 'TOÀN BỘ'}]
  else if Session.get("currentPriceBook").priceBookType is 1
    Schema.customers.find({}).fetch()
#  else if Session.get("currentPriceBook").priceBookType is 2
#    Schema.customers.find({}).fetch()
  else if Session.get("currentPriceBook").priceBookType is 3
    Schema.providers.find({}).fetch()
#  else if Session.get("currentPriceBook").priceBookType is 4
#    Schema.providers.find({}).fetch()

priceBookOwnerFindOne = (owners)->
  if Session.get("currentPriceBook").priceBookType is 0
    {_id: 0, name: 'TẤT CẢ'}
  else if Session.get("currentPriceBook").priceBookType is 1
    Schema.customers.findOne(owners[0])
  #  else if Session.get("currentPriceBook").priceBookType is 2
  #    Schema.customers.find({}).fetch()
  else if Session.get("currentPriceBook").priceBookType is 3
    Schema.providers.findOne(owners[0])
  #  else if Session.get("currentPriceBook").priceBookType is 4
  #    Schema.providers.find({}).fetch()


formatOwnerSearch = (item) -> "#{item.name}" if item
Apps.Merchant.priceBookInit.push (scope) ->
  scope.priceBookOwnerSelectOptions =
    query: (query) -> query.callback
      results: priceBookOwnerSearch(query)
      text: 'name'
    initSelection: (element, callback) -> callback priceBookOwnerFindOne(scope.currentPriceBook.owners)
    formatSelection: formatOwnerSearch
    formatResult: formatOwnerSearch
    id: '_id'
    placeholder: 'CHỌN ĐỐI TƯỢNG ÁP DỤNG'
    changeAction: (e) ->
      scope.currentPriceBook.changeOwner(e.added._id)

    reactiveValueGetter: ->
      if Session.get("currentPriceBook").priceBookType is 0 then {_id: 0, name: 'TẤT CẢ'}
      else
        if Session.get('currentPriceBook').owners is undefined then 'skyReset'
        else Session.get('currentPriceBook').owners[0]


priceBookSearch  = (query) ->
  lists = []
  if Session.get("currentPriceBook").priceBookType is 0
    customerGroups = Schema.customerGroups.find({$or: [{name: Helpers.BuildRegExp(query.term), isBase: false, merchant: Merchant.getId()}]}).fetch()
    customers = Schema.customers.find({$or: [{name: Helpers.BuildRegExp(query.term), merchant: Merchant.getId()}]}).fetch()
    providers = Schema.providers.find({$or: [{name: Helpers.BuildRegExp(query.term), merchant: Merchant.getId()}]}).fetch()
    lists = _.union(customerGroups, customers, providers)

  else if Session.get("currentPriceBook").priceBookType is 2
    if customerGroup = Schema.customerGroups.findOne(Session.get("currentPriceBook").owner)
      lists = Schema.customers.find({$or: [{name: Helpers.BuildRegExp(query.term), _id:{$in:customerGroup.customers}}]}).fetch()

  lists


formatPriceBookSearch = (item) ->
  if item
    return "#{item.name}" if item.model is 'customers'
    return "Vùng - #{item.name}" if item.model is 'customerGroups'

Apps.Merchant.priceBookInit.push (scope) ->
  scope.priceBookSelectOptions =
    query: (query) -> query.callback
      results: priceBookSearch(query)
      text: 'name'
    initSelection: (element, callback) -> callback 'skyReset'
    formatSelection: formatPriceBookSearch
    formatResult: formatPriceBookSearch
    id: '_id'
    placeholder: 'CHỌN VÙNG HOẶC KHÁCH HÀNG'
    changeAction: (e) -> scope.currentPriceBook.changePriceProductTo(e.added._id, e.added.model)
    reactiveValueGetter: -> 'skyReset'