Meteor.publish 'availableWarehouse', ->
  myProfile = Schema.userProfiles.findOne({user: @userId})
  return [] if !myProfile
  Schema.warehouses.find({merchant: myProfile.currentMerchant})

Meteor.publish 'allWarehouse', ->
  myProfile = Schema.userProfiles.findOne({user: @userId})
  return [] if !myProfile
  Schema.warehouses.find({parentMerchant: myProfile.parentMerchant})

