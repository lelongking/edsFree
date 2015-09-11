Enums = Apps.Merchant.Enums
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
#  Schema.transactions.find().forEach(
#    (transaction)->
#      Schema.transactions.update transaction._id, $set:{isBeginCash: true}
#  )
  scope.resetShowEditCommand = -> Session.set "customerManagementShowEditCommand"
  scope.transactionFind = (parentId)-> Schema.transactions.find({parent: parentId}, {sort: {'version.createdAt': 1}})
  scope.findOldDebtCustomer = ->
    if customerId = Session.get("customerManagementCustomerId")
      transaction = Schema.transactions.find({owner: customerId, parent:{$exists: false}}, {sort: {'version.createdAt': 1}})
      transactionCount = transaction.count(); count = 0
      transaction.map(
        (transaction) ->
          count += 1
          transaction.isLastTransaction = true if count is transactionCount
          transaction
      )
    else []

  scope.findAllOrders = ->
    if customerId = Session.get("customerManagementCustomerId")
      orders = Schema.orders.find({
        buyer     : customerId
        orderType  : Enums.getValue('OrderTypes', 'success')
        orderStatus: Enums.getValue('OrderStatus', 'finish')
      }).map(
        (item) ->
          item.transactions = scope.transactionFind(item._id).fetch()
          item.transactions[item.transactions.length-1].isLastTransaction = true if item.transactions.length > 0
          item
      )

      returns = Schema.returns.find({
        owner       : customerId
        returnType  : Enums.getValue('ReturnTypes', 'customer')
        returnStatus: Enums.getValue('ReturnStatus', 'success')
      }).map(
        (item) ->
          item.transactions = scope.transactionFind(item._id).fetch()
          item.transactions[item.transactions.length-1].isLastTransaction = true if item.transactions.length > 0
          item
      )

      dataSource = _.sortBy(orders.concat(returns), (item) -> item.successDate )

      classColor = false
      for item in dataSource
        item.classColor = classColor
        classColor = !classColor
      dataSource

    else []