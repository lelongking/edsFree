Meteor.publish null, ->
  merchantId = Meteor.users.findOne(@userId)?.profile?.merchant
  Schema.merchants.find({_id: merchantId})

Meteor.publish null, -> Schema.products.find()
Meteor.publish null, -> Meteor.users.find({_id: @userId}, {fields: {'sessions': 1} })