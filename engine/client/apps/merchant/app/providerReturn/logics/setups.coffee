Enums = Apps.Merchant.Enums
Apps.Merchant.providerReturnInit.push (scope) ->
  scope.tabProviderReturnOptions =
    source: Return.findNotSubmitOf('provider')
    currentSource: 'currentProviderReturn'
    caption: 'returnName'
    key: '_id'
    createAction  : -> Return.insert(Enums.getValue('ReturnTypes', 'provider'))
    destroyAction : (instance) -> if instance then instance.remove(); Return.findNotSubmitOf('provider').count() else -1
    navigateAction: (instance) -> Return.setReturnSession(instance._id, 'provider')

  scope.providerSelectOptions =
    query: (query) -> query.callback
      results: providerSearch(query)
      text: 'name'
    initSelection: (element, callback) -> callback Schema.providers.findOne(scope.currentProviderReturn.owner)
    formatSelection: formatProviderSearch
    formatResult: formatProviderSearch
    id: '_id'
    placeholder: 'CHỌN NHÀ CUNG CẤP'
    readonly: -> true
    changeAction: (e) -> scope.currentProviderReturn.selectOwner(e.added._id)
    reactiveValueGetter: -> Session.get('currentProviderReturn')?.owner ? 'skyReset'

  scope.importSelectOptions =
    query: (query) -> query.callback
      results: findImportByProvider(Session.get('currentProviderReturn')?.owner)
      text: '_id'
    initSelection: (element, callback) -> callback Schema.imports.findOne(scope.currentProviderReturn?.parent)
    formatSelection: (item) -> "#{item.importCode}" if item
    formatResult: (item) -> "#{item.importCode}" if item
    id: '_id'
    placeholder: 'CHỌN PHIẾU NHẬP'
    minimumResultsForSearch: -1
    readonly: -> true
    changeAction: (e) -> scope.currentProviderReturn.selectParent(e.added._id)
    reactiveValueGetter: -> Session.get('currentProviderReturn')?.parent ? 'skyReset'

providerSearch = (query) ->
  selector = {merchant: Merchant.getId(), billNo: {$gt: 0}}; options = {sort: {nameSearch: 1}}
  if(query.term)
    regExp = Helpers.BuildRegExp(query.term);
    selector = {$or: [
      {nameSearch: regExp, merchant: Merchant.getId(), billNo: {$gt: 0}}
    ]}
  Schema.providers.find(selector, options).fetch()

findImportByProvider = (providerId) ->
  importLists = []
  if providerId
    importLists = Schema.imports.find({
      merchant   : Merchant.getId()
      provider   : providerId
      importType : Enums.getValue('ImportTypes', 'success')
    }).fetch()
  importLists


formatProviderSearch = (item) ->
  if item
    name = "#{item.name} "; desc = if item.description then "(#{item.description})" else ""
    name + desc
