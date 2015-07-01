formatProductSearch = (item) -> "#{item.name}" if item

Apps.Merchant.productGroupInit.push (scope) ->
  scope.productGroupSelects =
    query: (query) -> query.callback
      results: Schema.productGroups.find({$or: [{name: Helpers.BuildRegExp(query.term), _id: {$not:scope.currentProductGroup._id }}]}).fetch()
      text: 'name'
    initSelection: (element, callback) -> callback 'skyReset'
    formatSelection: formatProductSearch
    formatResult: formatProductSearch
    id: '_id'
    placeholder: 'CHỌN NHÓM'
    changeAction: (e) -> scope.currentProductGroup.changeProductTo(e.added._id)
    reactiveValueGetter: -> 'skyReset'

