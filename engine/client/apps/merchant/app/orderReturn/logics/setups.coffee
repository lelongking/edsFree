#formatCustomerSearch = (item) ->
#  if item
#    name = "#{item.name} "
#    desc = if item.description then "(#{item.description})" else ""
#    name + desc
#changedActionSelectCustomer = (customer, currentCustomerReturn)->
#  Schema.returns.update currentCustomerReturn._id,
#    $set: {
#      customer: customer._id
#      tabDisplay: Helpers.shortName2(customer.name)
#    }
#    ,
#    $unset:{
#      import: true
#      timeLineImport: true
#      distributor: true
#    }
#
#Apps.Merchant.customerReturnInit.push (scope) ->
#  scope.customerSelectOptions =
#    query: (query) -> query.callback
#      results: _.filter Schema.customers.find().fetch(), (item) ->
#        unsignedTerm = Helpers.RemoveVnSigns query.term
#        unsignedName = Helpers.RemoveVnSigns item.name
#
#        unsignedName.indexOf(unsignedTerm) > -1
#      text: 'name'
#    initSelection: (element, callback) -> callback(Schema.customers.findOne(Session.get('currentCustomerReturn')?.owner ? 'skyReset'))
#    formatSelection: formatCustomerSearch
#    formatResult: formatCustomerSearch
#    id: '_id'
#    placeholder: 'CHỌN NGƯỜI MUA'
#    changeAction: (e) -> changedActionSelectCustomer(e.added, Session.get('currentCustomerReturn'))
#    reactiveValueGetter: -> Session.get('currentCustomerReturn')?.owner ? 'skyReset'