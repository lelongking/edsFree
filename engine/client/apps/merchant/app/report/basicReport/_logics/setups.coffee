Enums = Apps.Merchant.Enums

Apps.Merchant.basicReportInit.push (scope) ->
  scope.customerSelectOptions =
    query: (query) -> query.callback
      results: customerSearch(query)
      text: 'name'
    initSelection: (element, callback) -> callback Schema.customers.findOne()
    formatSelection: formatCustomerSearch
    formatResult: formatCustomerSearch
    id: '_id'
    placeholder: 'CHỌN KHÁCH HÀNG'
    changeAction: (e) ->
    reactiveValueGetter: ->

formatCustomerSearch = (item) -> "#{item.name}" if item
customerSearch = (query) ->
  selector = {merchant: Merchant.getId(), billNo: {$gt: 0}}; options = {sort: {nameSearch: 1}}
  if(query.term)
    regExp = Helpers.BuildRegExp(query.term);
    selector = {$or: [
      {nameSearch: regExp, merchant: Merchant.getId(), billNo: {$gt: 0}}
    ]}
  Schema.customers.find(selector, options).fetch()