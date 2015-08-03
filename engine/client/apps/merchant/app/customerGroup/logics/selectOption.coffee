formatCustomerSearch = (item) -> "#{item.name}" if item

Apps.Merchant.customerGroupInit.push (scope) ->
  scope.customerGroupSelects =
    query: (query) -> query.callback
      results: Schema.customerGroups.find({$or: [{name: Helpers.BuildRegExp(query.term), _id: {$not:scope.currentCustomerGroup._id }}]}).fetch()
      text: 'name'
    initSelection: (element, callback) -> callback 'skyReset'
    formatSelection: formatCustomerSearch
    formatResult: formatCustomerSearch
    id: '_id'
    placeholder: 'CHỌN NHÓM'
    changeAction: (e) -> scope.currentCustomerGroup.changeCustomerTo(e.added._id) if User.hasManagerRoles()
    reactiveValueGetter: -> 'skyReset'

