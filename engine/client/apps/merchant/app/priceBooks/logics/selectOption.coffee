formatDefaultSearch  = (item) -> "#{item.display}" if item
findPriceBookTypes   = (priceBookTypeId)-> _.findWhere(Apps.Merchant.PriceBookTypes, {_id: priceBookTypeId})
Apps.Merchant.priceBookInit.push (scope) ->
  scope.priceBookTypeSelectOptions =
    query: (query) -> query.callback
      results: Apps.Merchant.PriceBookTypes
      text: '_id'
    initSelection: (element, callback) -> callback findPriceBookTypes(Session.get('currentPriceBook').priceBookType)
    formatSelection: formatDefaultSearch
    formatResult: formatDefaultSearch
    placeholder: 'LOẠI BẢN GIÁ THEO'
    minimumResultsForSearch: -1
    changeAction: (e) ->
      scope.currentPriceBook.changePriceBookType(e.added._id)
      PriceBookSearch.search PriceBookSearch.getCurrentQuery()
      PriceBookSearch.cleanHistory()
    reactiveValueGetter: -> findPriceBookTypes(Session.get('currentPriceBook').priceBookType)

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


#    query: (query) -> query.callback
#      results: Schema.customers.find().fetch()
#    initSelection: (element, callback) -> callback Session.get('currentRoleSelection')
#    changeAction: (e) ->
#      currentRoles = Session.get('currentRoleSelection')
#      currentRoles = currentRoles ? []
#
#      currentRoles.push e.added if e.added
#      if e.removed
#        removedItem = _.findWhere(currentRoles, {_id: e.removed._id})
#        currentRoles.splice currentRoles.indexOf(removedItem), 1
#
#      Session.set('currentRoleSelection', currentRoles)
#    reactiveValueGetter: -> Session.get('currentRoleSelection')
#    formatSelection: formatRoleSelect
#    formatResult: formatRoleSelect
#    others:
#      multiple: true
#      maximumSelectionSize: 3
