Enums = Apps.Merchant.Enums
Meteor.publish null, ->
  collections = []
  return collections if !@userId
  merchantId = Meteor.users.findOne(@userId)?.profiles?.merchant
  return collections if !merchantId

  Counts.publish @, 'products', Schema.products.find({merchant: merchantId})
  Counts.publish @, 'productGroups', Schema.productGroups.find({isBase: false, merchant: merchantId})

  Counts.publish @, 'customers', Schema.customers.find({merchant: merchantId})
  Counts.publish @, 'customerReturns', Schema.returns.find({returnType: 0, merchant: merchantId})
  Counts.publish @, 'customerGroups', Schema.customerGroups.find({isBase: false, merchant: merchantId})

  Counts.publish @, 'orders', Schema.orders.find({orderType:{$in: [1,2]}, merchant: merchantId})
  Counts.publish @, 'deliveries', Schema.orders.find({orderType:2, 'delivery.status': {$in: [1,2,3,4]}, merchant: merchantId})

  Counts.publish @, 'providers', Schema.providers.find({merchant: merchantId})
  Counts.publish @, 'providerReturns', Schema.returns.find({returnType: 1, merchant: merchantId})

  Counts.publish @, 'imports', Schema.imports.find({importType: Enums.getValue('ImportTypes', 'success'),  merchant: merchantId})
  Counts.publish @, 'inventories', Schema.inventories.find({merchant: merchantId})

  Counts.publish @, 'users', Meteor.users.find({merchant: merchantId})
  Counts.publish @, 'priceBooks', Schema.priceBooks.find({merchant: merchantId})

  collections.push Schema.merchants.find({_id: merchantId})
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
  collections.push Meteor.users.find({_id: @userId}, {fields: {profiles: 1, sessions: 1} })

  return collections