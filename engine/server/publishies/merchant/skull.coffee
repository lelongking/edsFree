Meteor.publish 'skulls', ->
  myProfile = Schema.userProfiles.findOne({user: @userId})
  return [] if !myProfile
  Schema.skulls.find({parentMerchant: myProfile.parentMerchant})

