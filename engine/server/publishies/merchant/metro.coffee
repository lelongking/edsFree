Meteor.publish 'myMetroSummaries', ->
  myProfile = Schema.userProfiles.findOne({user: @userId})
  return [] if !myProfile
  Schema.metroSummaries.find({parentMerchant: myProfile.parentMerchant, merchant: myProfile.currentMerchant})

