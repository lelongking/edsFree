Enums = Apps.Merchant.Enums
Meteor.publish null, ->
  collections = []
  return collections if !@userId
  myProfile  = Meteor.users.findOne(@userId)?.profile
  merchantId = myProfile.merchant if myProfile
  return collections if !merchantId

  #all
  Counts.publish @, 'products', Schema.products.find({merchant: merchantId})
  Counts.publish @, 'productGroups', Schema.productGroups.find({merchant: merchantId})

  Counts.publish @, 'customers', Schema.customers.find({merchant: merchantId})
  Counts.publish @, 'customerReturns', Schema.returns.find({returnType: 0, merchant: merchantId})
  Counts.publish @, 'customerGroups', Schema.customerGroups.find({merchant: merchantId})


  Counts.publish @, 'deliveries', Schema.orders.find({orderType:2, 'delivery.status': {$in: [1,2,3,4]}, merchant: merchantId})

  Counts.publish @, 'providers', Schema.providers.find({merchant: merchantId})
  Counts.publish @, 'providerReturns', Schema.returns.find({returnType: 1, merchant: merchantId})

  Counts.publish @, 'imports', Schema.imports.find({importType: Enums.getValue('ImportTypes', 'success'),  merchant: merchantId})
  Counts.publish @, 'inventories', Schema.inventories.find({merchant: merchantId})

  Counts.publish @, 'staffs', Meteor.users.find({'profile.merchant': merchantId})
  Counts.publish @, 'priceBooks', Schema.priceBooks.find({merchant: merchantId})

  orderQuery =
    merchant    : merchantId
    orderType   : Enums.getValue('OrderTypes', 'initialize')
    orderStatus : Enums.getValue('OrderStatus', 'initialize')
  Counts.publish @, 'orders', Schema.orders.find(orderQuery)

  billQuery =
    merchant    : merchantId
    orderType   : {$in:[
      Enums.getValue('OrderTypes', 'tracking')
      Enums.getValue('OrderTypes', 'success')
      Enums.getValue('OrderTypes', 'fail')
    ]}
    orderStatus : {$in:[
      Enums.getValue('OrderStatus', 'sellerConfirm')
      Enums.getValue('OrderStatus', 'accountingConfirm')
      Enums.getValue('OrderStatus', 'exportConfirm')
      Enums.getValue('OrderStatus', 'success')
      Enums.getValue('OrderStatus', 'fail')
      Enums.getValue('OrderStatus', 'importConfirm')
    ]}
  Counts.publish @, 'billManagers', Schema.orders.find(billQuery)

  orderFinishQuery =
    merchant    : merchantId
    orderType   : Enums.getValue('OrderTypes', 'success')
    orderStatus : Enums.getValue('OrderStatus', 'finish')
  Counts.publish @, 'orderManagers', Schema.orders.find(orderFinishQuery)

  # Giao dien hien thi cho Nhan vien
  Counts.publish @, 'customerOfStaff', Schema.customers.find({staff: @userId, merchant: merchantId})

  orderQuery.creator = @userId
  Counts.publish @, 'orderOfStaff', Schema.orders.find(orderQuery)

  billQuery.creator = @userId
  Counts.publish @, 'billManagerOfStaff', Schema.orders.find(billQuery)

  orderFinishQuery.creator = @userId
  Counts.publish @, 'orderHistoryOfStaff', Schema.orders.find(orderFinishQuery)

  customerGroupQuery = merchant: merchantId, customers: {$in: myProfile.customers ? []}
  Counts.publish @, 'customerGroupOfStaff', Schema.customerGroups.find(customerGroupQuery)

  Counts.publish @, 'customerReturnHistories', Schema.returns.find(
    merchant    : merchantId
    returnType  : Enums.getValue('ReturnTypes', 'customer')
    returnStatus: Enums.getValue('ReturnStatus', 'success')
  )
  Counts.publish @, 'providerReturnHistories', Schema.returns.find(
    merchant    : merchantId
    returnType  : Enums.getValue('ReturnTypes', 'provider')
    returnStatus: Enums.getValue('ReturnStatus', 'success')
  )




  collections.push Schema.notifications.find()
  collections.push Schema.messages.find({receiver: @userId}, {sort: {'version.createdAt': -1}, limit: 10})
  collections.push Schema.merchants.find({_id: merchantId})
  collections.push AvatarImages.find({})
  collections.push Schema.products.find()
  collections.push Schema.productGroups.find()
  collections.push Schema.customers.find()
  collections.push Schema.customerGroups.find()
  collections.push Schema.providers.find()
  collections.push Schema.returns.find()
  collections.push Schema.orders.find()
  collections.push Schema.imports.find()
  collections.push Schema.priceBooks.find()
  collections.push Schema.transactions.find()
  collections.push Meteor.users.find({'profile.merchant': merchantId}, {fields: {
    emails:1, profile: 1, sessions: 1, creator: 1, status: 1, allowDelete : 1
  } })

  return collections