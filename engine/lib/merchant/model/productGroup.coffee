simpleSchema.productGroups = new SimpleSchema
  name        : simpleSchema.StringUniqueIndex
  nameSearch  : simpleSchema.searchSource('name')
  description : simpleSchema.OptionalString
  products    : type: [String], defaultValue: []
  priceBook   : simpleSchema.OptionalString

  merchant    : simpleSchema.DefaultMerchant
  allowDelete : simpleSchema.DefaultBoolean()
  creator     : simpleSchema.DefaultCreator
  version     : { type: simpleSchema.Version }
  isBase      :
    type: Boolean
    autoValue: ->
      if @isInsert
        return false
      else if @isUpsert
        return { $setOnInsert: false }

      return

Schema.add 'productGroups', "ProductGroup", class ProductGroup
  @transform: (doc) ->
    doc.productCount = -> if @products then @products.length else 0
    doc.remove = ->
      if @allowDelete
        Schema.productGroups.remove(@_id)
        findProductGroup = Schema.productGroups.findOne({isBase: true, merchant: Merchant.getId()})
        ProductGroup.setSessionProductGroup(findProductGroup._id) if findProductGroup

    doc.changeProductTo = (productGroupId) ->
      if user = Meteor.users.findOne(Meteor.userId())
        productList = []; productSelected = user.sessions.productSelected[@_id]
        for productId in productSelected
          if productFound = Schema.products.findOne({_id: productId, group: @_id})
            Schema.products.update(productFound._id, $set: {group: productGroupId})
            productList.push(productFound._id)


        updateGroupFrom = $pullAll:{products: productSelected}
        productNotExistedCount = (_.difference(@products, productSelected)).length
        updateGroupFrom.$set = {allowDelete: true} if productNotExistedCount is 0 and @isBase is false
        Schema.productGroups.update @_id, updateGroupFrom

        updateGroupTo = $set:{allowDelete: false}, $addToSet:{products: {$each: productList}}
        Schema.productGroups.update productGroupId, updateGroupTo

        userUpdate = $set:{}; userUpdate.$set["sessions.productSelected.#{@_id}"] = []
        Meteor.users.update(user._id, userUpdate)

    doc.selectedProduct = (productId)->
      if userId = Meteor.userId()
        userUpdate = $addToSet:{}; userUpdate.$addToSet["sessions.productSelected.#{@_id}"] = productId
        Meteor.users.update(userId, userUpdate)

    doc.unSelectedProduct = (productId)->
      if userId = Meteor.userId()
        userUpdate = $pull:{}; userUpdate.$pull["sessions.productSelected.#{@_id}"] = productId
        Meteor.users.update(userId, userUpdate)

  @insert: (name, description)->
    return false if !name

    newGroup = {name: name}
    newGroup.description = description if description
    newProductId = Schema.productGroups.insert newGroup
    ProductGroup.setSessionProductGroup(newProductId) if newProductId
    newProductId

  @nameIsExisted: (name, merchant = Merchant.getId()) ->
    return true if !merchant or !name
    existedQuery = {name: name, merchant: merchant}
    if Schema.productGroups.findOne(existedQuery) then true else false

  @setSessionProductGroup: (productGroupId) ->
    return false if !productGroupId
    #    Meteor.subscribe('productManagementCurrentProductData', @_id) if Meteor.isClient
    Meteor.users.update(Meteor.userId(), {$set: {'sessions.currentProductGroup': productGroupId}})

  @getBasicGroup: -> Schema.productGroups.findOne {isBase: true, merchant: Merchant.getId()}

  @addProduct: (productId)->
    product = Schema.products.findOne(productId)
    group = Schema.productGroups.findOne({isBase: true})

    if product and group
      Schema.products.update(product._id, $set: {group: group._id})
      Schema.productGroups.update(group, $pull: {products: product._id }) if product.group
      Schema.productGroups.update(group._id, $addToSet: {products: product._id })

  @reAddProduct: ->
    if productGroup = Schema.productGroups.findOne({isBase: true, merchant: Merchant.getId()})
      productList = []
      Schema.products.find({merchant: Merchant.getId(), group: {$exists: false}}).forEach(
        (product) ->
          productList.push(product._id)
          Schema.products.update product._id, $set: {group: productGroup._id}
      )
      Schema.productGroups.update productGroup._id, $addToSet:{products: {$each:productList}}
