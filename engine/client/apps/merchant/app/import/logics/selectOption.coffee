updateImportAndProduct = (e)->
  if e.added
    if e.added.merchantType then importUpdate = {$set: {partner: e.added._id}, $unset: {distributor: true}}
    else importUpdate = {$set: {distributor: e.added._id}, $unset: {partner: true}}
    importUpdate.$set.tabDisplay = Helpers.shortName2(e.added.name)
  else
    importUpdate = { $set:{tabDisplay: 'Nhập kho'}, $unset:{distributor: true, partner: true} }
  Schema.imports.update Session.get('currentImport')._id, importUpdate


providerSearch       = (query) -> ProviderSearch.search(query.term); ProviderSearch.getData({sort: {name: 1}})
formatProviderSearch = (item) -> "#{item.name}" if item
Apps.Merchant.importInit.push (scope) ->
  scope.providerSelectOptions =
    query: (query) -> query.callback
      results: providerSearch(query)
      text: 'name'
    initSelection: (element, callback) -> callback Schema.providers.findOne(scope.currentImport.provider)
    formatSelection: formatProviderSearch
    formatResult: formatProviderSearch
    id: '_id'
    placeholder: 'CHỌN NHÀ PHÂN PHỐI'
    changeAction: (e) -> scope.currentImport.changeField('provider', e.added._id)
    reactiveValueGetter: -> Session.get('currentImport')?.provider ? 'skyReset'
