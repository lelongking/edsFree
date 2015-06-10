Meteor.publish 'myMerchantProfile', ->
  return [] if !@userId
  profile = Schema.userProfiles.findOne({user: @userId})
  return [] if !profile
  Schema.merchantProfiles.find({merchant: profile.parentMerchant})

