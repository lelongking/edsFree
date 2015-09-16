Enums = Apps.Merchant.Enums
Meteor.methods
  deleteReturn: (returnId, ownerId, returnType = Enums.getValue('ReturnTypes', 'customer'))->
    user = Meteor.users.findOne(Meteor.userId())
    return {valid: false, error: 'user not found!'} unless user
    return {valid: false, error: 'user not permission!'} unless User.hasManagerRoles()

    merchantFound = Schema.merchants.findOne(user.profile.merchant)
    return {valid: false, error: 'merchant not found!'} unless merchantFound

    returnTypes = [Enums.getValue('ReturnTypes', 'customer'), Enums.getValue('ReturnTypes', 'provider')]
    return {valid: false, error: 'returnType is valid!'} unless _.contains(returnTypes, returnType)

    query =
      owner        : ownerId
      parent       : $exists: true
      merchant     : user.profile.merchant
      returnType   : returnType
      returnStatus : Enums.getValue('ReturnStatus', 'success')

    currentReturnQuery = _.clone(query)
    currentReturnQuery._id = returnId

    currentReturnFound = Schema.returns.findOne currentReturnQuery
    return {valid: false, error: 'return not found!'} unless currentReturnFound
    return {valid: false, error: 'return not delete!'} unless currentReturnFound.allowDelete

#Xoa Tra hang
    if returnType
      orderFound = Schema.orders.findOne(currentReturnFound.owner)
      return {valid: false, error: 'order not found!'} unless orderFound












    else
      providerFound = Schema.providers.findOne(currentReturnFound.provider)
      return {valid: false, error: 'provider not found!'} unless providerFound and currentReturnFound.provider


