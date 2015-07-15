logics.customerManagement = {}
Apps.Merchant.customerManagementInit = []
Apps.Merchant.customerManagementReactive = []

Apps.Merchant.customerManagementReactive.push (scope) ->
  scope.currentCustomer = Schema.customers.findOne(Session.get('mySession').currentCustomer)
  Session.set "customerManagementCurrentCustomer", scope.currentCustomer

  customerId = if scope.currentCustomer?._id then scope.currentCustomer._id else false
  if Session.get("customerManagementCustomerId") isnt customerId
    Session.set "customerManagementCustomerId", customerId



Apps.Merchant.customerManagementInit.push (scope) ->
  scope.resetShowEditCommand = -> Session.set "customerManagementShowEditCommand"
  scope.transactionFind = (parentId)-> Schema.transactions.find({parent: parentId}, {sort: {'version.createdAt': 1}})
  scope.findOldDebtCustomer = ->
    if customerId = Session.get("customerManagementCustomerId")
      Schema.transactions.find({owner: customerId, parent:{$exists: false}}, {sort: {'version.createdAt': 1}})
    else []

  scope.findAllOrders = ->
    if customerId = Session.get("customerManagementCustomerId")
      orders = Schema.orders.find({buyer: customerId, importType: 4}).map(
        (item) -> item.transactions = scope.transactionFind(item._id);  item
      )
      returns = Schema.returns.find({owner: customerId, importType: 4}).map(
        (item) -> item.transactions = scope.transactionFind(item._id);  item
      )
      _.sortBy orders.concat(returns), (item) -> item.version.createdAt
    else []