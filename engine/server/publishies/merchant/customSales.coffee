#Meteor.publishComposite 'availableCustomSaleOf', (customerId)->
#  self = @
#  return {
#    find: ->
#      myProfile = Schema.userProfiles.findOne({user: self.userId})
#      return EmptyQueryResult if !myProfile
#      Schema.customSales.find {buyer: customerId, parentMerchant: myProfile.parentMerchant}
#    children: [
#      find: (customSale) -> Schema.customSaleDetails.find {customSale: customSale._id}
#    ,
#      find: (customSale) -> Schema.transactions.find {latestSale: customSale._id}
#    ]
#  }

