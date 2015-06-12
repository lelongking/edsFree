Meteor.publish null, ->
#  profile = Schema.userProfiles.findOne({user: @userId})
  return [] if !@userId

  Counts.publish @, 'products', Schema.products.find()
  Counts.publish @, 'customers', Schema.customers.find()
  return

Meteor.publish null, ->
  merchantId = Meteor.users.findOne(@userId)?.profile?.merchant
  Schema.merchants.find({_id: merchantId})

Meteor.publish null, -> Schema.products.find()
Meteor.publish null, -> Schema.customers.find()
Meteor.publish null, -> Meteor.users.find({_id: @userId}, {fields: {'sessions': 1} })

