Meteor.publish 'providers', ->
  myProfile = Schema.userProfiles.findOne({user: @userId})
  return [] if !myProfile
  Schema.providers.find({parentMerchant: myProfile.parentMerchant})

Meteor.publishComposite 'allProductDetailBy', (providerId)->
  self = @
  return {
  find: ->
    myProfile = Schema.userProfiles.findOne({user: self.userId})
    return EmptyQueryResult if !myProfile
    Schema.productDetails.find({provider: providerId})
  children: [
    find: (productDetail) -> Schema.products.find {_id: productDetail.product}
  ]
  }

Meteor.publishComposite 'allImportDetailBy', (providerId)->
  self = @
  return {
  find: ->
    myProfile = Schema.userProfiles.findOne({user: self.userId})
    return EmptyQueryResult if !myProfile
    Schema.importDetails.find({provider: providerId, submitted: true})
  children: [
    find: (importDetail) -> Schema.imports.find {_id: importDetail.import}
  ]
  }

