Enums = Apps.Merchant.Enums
simpleSchema.returns = new SimpleSchema
  returnMethods    : simpleSchema.DefaultNumber()

  owner  : simpleSchema.OptionalString
  parent : simpleSchema.OptionalString

  returnName  : type: String, defaultValue: 'Trả hàng'
  description : simpleSchema.OptionalString
  returnCode  : simpleSchema.OptionalString

  returnType  : type: Number,  defaultValue: Enums.getValue('ReturnTypes', 'customer')
  returnStatus: type: Number,  defaultValue: Enums.getValue('ReturnStatus', 'initialize')

  discountCash : type: Number, defaultValue: 0
  depositCash  : type: Number, defaultValue: 0
  totalPrice   : type: Number, defaultValue: 0
  finalPrice   : type: Number, defaultValue: 0

  merchant    : simpleSchema.DefaultMerchant
  allowDelete : simpleSchema.DefaultBoolean()
  creator     : simpleSchema.DefaultCreator
  version: { type: simpleSchema.Version }

  details                   : type: [Object], defaultValue: []
  'details.$._id'           : simpleSchema.UniqueId
  'details.$.product'       : type: String
  'details.$.productUnit'   : type: String
  'details.$.quality'       : {type: Number, min: 0}
  'details.$.price'         : {type: Number, min: 0}
  'details.$.basicQuality'  : {type: Number, min: 0}
  'details.$.conversion'    : {type: Number, min: 1}
  'details.$.discountCash'  : simpleSchema.DefaultNumber()

Schema.add 'returns', "Return", class Return
  @transform: (doc) ->
    doc.remove = ->
      Schema.returns.remove @_id if @allowDelete and User.hasManagerRoles()

    doc.changeDescription = (description)->
      option = $set:{'profiles.description': description}
      Schema.returns.update @_id, option

    doc.selectOwner = (ownerId)->
      if @returnType is Enums.getValue('ReturnTypes', 'customer')
        if customer = Schema.customers.findOne ownerId
          changeOwnerUpdate = $unset:{parent: true}, $set:{
            owner       : customer._id
            returnName  : Helpers.shortName2(customer.name)
            discountCash: 0
            depositCash : 0
            totalPrice  : 0
            finalPrice  : 0
            details     : []
          }
      else if @returnType is Enums.getValue('ReturnTypes', 'provider')
        if provider = Schema.providers.findOne ownerId
          changeOwnerUpdate = $unset:{parent: true}, $set:{
            owner       : provider._id
            returnName  : Helpers.shortName2(provider.name)
            discountCash: 0
            depositCash : 0
            totalPrice  : 0
            finalPrice  : 0
            details     : []
          }

      Schema.returns.update(@_id, changeOwnerUpdate) if changeOwnerUpdate

    doc.selectParent = (parentId)->
      if @returnType is Enums.getValue('ReturnTypes', 'customer')
        parent = Schema.orders.findOne({_id: parentId, merchant: Merchant.getId(), buyer: @owner})
      else if @returnType is Enums.getValue('ReturnTypes', 'provider')
        parent = Schema.imports.findOne({_id: parentId, merchant: Merchant.getId(), provider: @owner})

      if parent
        Schema.returns.update @_id, $set:{
          parent      : parent._id
          discountCash: 0
          depositCash : 0
          totalPrice  : 0
          finalPrice  : 0
          details     : []
        }

    doc.addReturnDetail = (productUnitId, quality = 1, callback)->
      product = Schema.products.findOne({'units._id': productUnitId})
      return console.log('Khong tim thay Product') if !product

      productUnit = _.findWhere(product.units, {_id: productUnitId})
      return console.log('Khong tim thay ProductUnit') if !productUnit

      price = product.getPrice(productUnitId, @provider, 'import')
      return console.log('Price not found..') if !price

      return console.log("Price invalid (#{price})") if price < 0
      return console.log("Quality invalid (#{quality})") if quality < 1

      detailFindQuery = {product: product._id, productUnit: productUnitId, price: price}
      detailFound = _.findWhere(@details, detailFindQuery)

      if detailFound
        detailIndex = _.indexOf(@details, detailFound)
        updateQuery = {$inc:{}}; basicQuality = quality * productUnit.conversion
        updateQuery.$inc["details.#{detailIndex}.quality"]          = quality
        updateQuery.$inc["details.#{detailIndex}.basicQuality"]     = basicQuality
        recalculationReturn(@_id) if Schema.returns.update(@_id, updateQuery, callback)

      else
        detailFindQuery.quality       = quality
        detailFindQuery.conversion    = productUnit.conversion
        detailFindQuery.basicQuality  = quality * productUnit.conversion
        recalculationReturn(@_id) if Schema.returns.update(@_id, { $push: {details: detailFindQuery} }, callback)

    doc.editReturnDetail = (detailId, quality, discountCash, price, callback) ->
      for instance, i in @details
        if instance._id is detailId
          updateIndex = i
          updateInstance = instance
          break
      return console.log 'ReturnDetailRow not found..' if !updateInstance

      predicate = $set:{}
      predicate.$set["details.#{updateIndex}.discountCash"] = discountCash  if discountCash isnt undefined
      predicate.$set["details.#{updateIndex}.price"] = price if price isnt undefined

      if quality isnt undefined
        basicQuality = quality * updateInstance.conversion
        predicate.$set["details.#{updateIndex}.quality"] = quality
        predicate.$set["details.#{updateIndex}.basicQuality"]     = basicQuality

      if _.keys(predicate.$set).length > 0
        recalculationReturn(@_id) if Schema.returns.update(@_id, predicate, callback)

    doc.removeReturnDetail = (detailId, callback) ->
      return console.log('Return không tồn tại.') if (!self = Schema.returns.findOne doc._id)
      return console.log('ReturnDetail không tồn tại.') if (!detailFound = _.findWhere(self.details, {_id: detailId}))
      detailIndex = _.indexOf(self.details, detailFound)
      removeDetailQuery = { $pull:{} }
      removeDetailQuery.$pull.details = self.details[detailIndex]
      recalculationReturn(@_id) if Schema.returns.update(@_id, removeDetailQuery, callback)

  @insert: (ownerId = undefined, parentId = undefined, returnType = Enums.getValue('OrderTypes', 'customer'))->
    insertOption = {}
    if Enums.getValue('OrderTypes', 'customer') is returnType or Enums.getValue('OrderTypes', 'provider') is returnType
      insertOption.returnType = returnType
    else return

    if ownerId
      ownerIsCustomer = Schema.customers.findOne(ownerId)
      ownerIsProvider = Schema.providers.findOne(ownerId) unless ownerIsCustomer

      if ownerIsCustomer
        parent = Schema.orders.findOne({
          _id         : parentId
          buyer       : ownerId
          orderType   : Enums.getValue('OrderTypes', 'success')
          orderStatus : Enums.getValue('OrderStatus', 'finish')
        })
      else if ownerIsProvider
        parent = Schema.imports.findOne({
          _id        : parentId
          provider   : ownerId
          importType : Enums.getValue('ImportTypes', 'success')
        })

      insertOption.parent = parentId if parent

      if ownerIsCustomer or ownerIsProvider
        insertOption.owner = ownerId
        if ownerIsCustomer
          insertOption.returnType = Enums.getValue('OrderTypes', 'customer')
          insertOption.returnName = Helpers.shortName2(ownerIsCustomer.name)
        else
          insertOption.returnType = Enums.getValue('OrderTypes', 'provider')
          insertOption.returnName = Helpers.shortName2(ownerIsProvider.name)

    Schema.returns.insert insertOption

  @findNotSubmitOf: (returnType = 'customer')->
    if returnType is 'customer' or returnType is 'provider'
      Schema.returns.find({
        creator     : Meteor.userId()
        merchant    : Merchant.getId()
        returnType  : Enums.getValue('ReturnTypes', returnType)
        returnStatus: Enums.getValue('ReturnStatus', 'initialize')
      })


  @setReturnSession: (returnId, returnType = 'customer')->
    if returnType is 'customer'
      updateSession = $set: {'sessions.currentCustomerReturn': returnId}
    else if returnType is 'provider'
      updateSession = $set: {'sessions.currentProviderReturn': returnId}

    Meteor.users.update(Meteor.userId(), updateSession) if updateSession

recalculationReturn = (returnId) ->
  if returnFound = Schema.returns.findOne(returnId)
    totalPrice = 0; discountCash = returnFound.profiles.discountCash
    (totalPrice += detail.quality * detail.price) for detail in returnFound.details
    discountCash = totalPrice if returnFound.profiles.discountCash > totalPrice
    Schema.returns.update returnFound._id, $set:{
      'profiles.totalPrice'  : totalPrice
      'profiles.discountCash': discountCash
      'profiles.finalPrice'  : totalPrice - discountCash
    }