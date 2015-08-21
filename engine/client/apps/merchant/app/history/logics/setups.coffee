Enums = Apps.Merchant.Enums

Apps.Merchant.basicReportInit.push (scope) ->
  scope.areaSelectOptions =
    query: (query) -> query.callback
      results: customerGroupSearch(query)
      text: 'name'
    initSelection: (element, callback) -> callback Session.get("basicReportDynamics").data
    formatSelection: formatCustomerGroupSearch
    formatResult: formatCustomerGroupSearch
    id: '_id'
    placeholder: 'CHỌN KHU VỰC'
    changeAction: (e) ->
      basicReport      = Session.get("basicReportDynamics")
      basicReport.data = e.added
      Session.set("basicReportDynamics", basicReport)
      d3.select('#revenueOfAreaReport').datum(logics.basicReport.customers).transition().duration(500).call(logics.basicReport.revenueOfArea)
    reactiveValueGetter: -> Session.get("basicReportDynamics").data

formatCustomerGroupSearch = (item) -> "#{item.name}" if item
customerGroupSearch = (query) ->
  selector = {merchant: Merchant.getId(), totalCash: {$gt: 0}}; options = {sort: {nameSearch: 1}}
  if(query.term)
    regExp = Helpers.BuildRegExp(query.term);
    selector = {$or: [
      {nameSearch: regExp, merchant: Merchant.getId(), totalCash: {$gt: 0}}
    ]}
  Schema.customerGroups.find(selector, options).fetch()

Apps.Merchant.basicReportInit.push (scope) ->
  scope.customerSelectOptions =
    query: (query) -> query.callback
      results: customerSearch(query)
      text: 'name'
    initSelection: (element, callback) -> callback Session.get("basicReportDynamics").data
    formatSelection: formatCustomerSearch
    formatResult: formatCustomerSearch
    id: '_id'
    placeholder: 'CHỌN KHÁCH HÀNG'
    changeAction: (e) ->
      basicReport      = Session.get("basicReportDynamics")
      basicReport.data = e.added
      Session.set("basicReportDynamics", basicReport)
      d3.select('#productOfCustomer')
      .datum(logics.basicReport.products)
      .transition().duration(500)
      .call(logics.basicReport.productOfCustomer)
    reactiveValueGetter: -> Session.get("basicReportDynamics").data

formatCustomerSearch = (item) -> "#{item.name}" if item
customerSearch = (query) ->
  selector = {merchant: Merchant.getId(), debtCash: {$gt: 0}}; options = {sort: {nameSearch: 1}}
  if(query.term)
    regExp = Helpers.BuildRegExp(query.term);
    selector = {$or: [
      {nameSearch: regExp, merchant: Merchant.getId(), debtCash: {$gt: 0}}
    ]}
  Schema.customers.find(selector, options).fetch()


#Apps.Merchant.basicReportInit.push (scope) ->
#  scope.customerSelectOptions =
#    query: (query) -> query.callback
#      results: customerSearch(query)
#      text: 'name'
#    initSelection: (element, callback) -> callback Session.get("basicReportDynamics").data
#    formatSelection: formatCustomerSearch
#    formatResult: formatCustomerSearch
#    id: '_id'
#    placeholder: 'CHỌN KHÁCH HÀNG'
#    changeAction: (e) ->
#      basicReport      = Session.get("basicReportDynamics")
#      basicReport.data = e.added
#      Session.set("basicReportDynamics", basicReport)
#      d3.select('#productByCustomer').datum(logics.basicReport.products).transition().duration(500).call(logics.basicReport.productOfCustomer)
#    reactiveValueGetter: -> Session.get("basicReportDynamics").data
#
#formatCustomerSearch = (item) -> "#{item.name}" if item
#customerSearch = (query) ->
#  selector = {merchant: Merchant.getId(), billNo: {$gt: 0}}; options = {sort: {nameSearch: 1}}
#  if(query.term)
#    regExp = Helpers.BuildRegExp(query.term);
#    selector = {$or: [
#      {nameSearch: regExp, merchant: Merchant.getId(), billNo: {$gt: 0}}
#    ]}
#  Schema.customers.find(selector, options).fetch()