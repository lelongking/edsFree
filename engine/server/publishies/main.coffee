Meteor.publish null, ->
  collections = []
  return collections if !@userId
  merchantId = Meteor.users.findOne(@userId)?.profiles?.merchant
  return collections if !merchantId

  Counts.publish @, 'products', Schema.products.find({merchant: merchantId})
  Counts.publish @, 'productGroups', Schema.productGroups.find({merchant: merchantId})
  Counts.publish @, 'customers', Schema.customers.find({merchant: merchantId})
  #  Counts.publish @, 'customerGroups', Schema.customerGroups.find({merchant: merchantId})
  Counts.publish @, 'providers', Schema.providers.find({merchant: merchantId})

  Counts.publish @, 'users', Meteor.users.find({'merchantId': merchantId})
  Counts.publish @, 'priceBooks', Schema.priceBooks.find({merchant: merchantId})

  #  Counts.publish @, 'inventories', Schema.providers.find({merchant: profile.merchant})

  Counts.publish @, 'orders', Schema.orders.find({orderType:{$in: [1,2]}, merchant: merchantId})
  Counts.publish @, 'deliveries', Schema.orders.find({orderType:2, 'deliveries.status': {$in: [1,2,3,4]}, merchant: merchantId})
  Counts.publish @, 'orderReturns', Schema.returns.find({merchant: merchantId})
  #  Counts.publish @, 'imports', Schema.imports.find({merchant: merchantId})
  #  Counts.publish @, 'importReturns', Schema.providers.find({merchant: profile.merchant})


  collections.push Schema.merchants.find({_id: merchantId})
  collections.push Schema.products.find()
  collections.push Schema.customers.find()
  collections.push Schema.providers.find()
  collections.push Schema.orders.find()
  collections.push Schema.imports.find()
  collections.push Schema.priceBooks.find()
  collections.push Meteor.users.find({_id: @userId}, {fields: {profiles: 1, sessions: 1} })

  return collections


