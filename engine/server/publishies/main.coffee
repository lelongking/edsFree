Meteor.publish null, ->
  return [] if !@userId
  profile = Meteor.users.findOne(@userId).profile
  return [] if !profile.merchant

  Counts.publish @, 'products', Schema.products.find({merchant: profile.merchant})
  Counts.publish @, 'productGroups', Schema.productGroups.find({merchant: profile.merchant})
  Counts.publish @, 'customers', Schema.customers.find({merchant: profile.merchant})
#  Counts.publish @, 'customerGroups', Schema.customerGroups.find({merchant: profile.merchant})
  Counts.publish @, 'providers', Schema.providers.find({merchant: profile.merchant})

  Counts.publish @, 'users', Meteor.users.find({'profiles.merchant': profile.merchant})
  Counts.publish @, 'priceBooks', Schema.priceBooks.find({merchant: profile.merchant})
#  Counts.publish @, 'deliveries', Schema.providers.find({merchant: profile.merchant})
#  Counts.publish @, 'inventories', Schema.providers.find({merchant: profile.merchant})

  Counts.publish @, 'orders', Schema.orders.find({merchant: profile.merchant})
  Counts.publish @, 'orderReturns', Schema.returns.find({merchant: profile.merchant})
  Counts.publish @, 'imports', Schema.imports.find({merchant: profile.merchant})
#  Counts.publish @, 'importReturns', Schema.providers.find({merchant: profile.merchant})

  return

Meteor.publish null, ->
  merchantId = Meteor.users.findOne(@userId)?.profile?.merchant
  Schema.merchants.find({_id: merchantId})

Meteor.publish null, -> Schema.products.find()
Meteor.publish null, -> Schema.customers.find()
Meteor.publish null, -> Schema.providers.find()
Meteor.publish null, -> Schema.orders.find()
Meteor.publish null, -> Schema.imports.find()
Meteor.publish null, -> Schema.priceBooks.find()
Meteor.publish null, -> Meteor.users.find({_id: @userId}, {fields: {'sessions': 1} })

