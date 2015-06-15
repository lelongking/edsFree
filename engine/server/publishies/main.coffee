Meteor.publish null, ->
  return [] if !@userId
  profile = Meteor.users.findOne(@userId).profile
  return [] if !profile.merchant

  Counts.publish @, 'products', Schema.products.find({merchant: profile.merchant})
  Counts.publish @, 'customers', Schema.customers.find({merchant: profile.merchant})
  Counts.publish @, 'providers', Schema.providers.find({merchant: profile.merchant})
  Counts.publish @, 'users', Meteor.users.find({'profiles.merchant': profile.merchant})
  return

Meteor.publish null, ->
  merchantId = Meteor.users.findOne(@userId)?.profile?.merchant
  Schema.merchants.find({_id: merchantId})

Meteor.publish null, -> Schema.products.find()
Meteor.publish null, -> Schema.customers.find()
Meteor.publish null, -> Schema.providers.find()
Meteor.publish null, -> Meteor.users.find({_id: @userId}, {fields: {'sessions': 1} })

