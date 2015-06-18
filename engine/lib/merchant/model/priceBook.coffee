simpleSchema.priceBooks = new SimpleSchema
  name          : {type: String ,unique  : true, index: 1}
  description   : {type: String ,optional: true}
  priceBookType : {type: Number ,defaultValue: 1}

  merchant    : simpleSchema.DefaultMerchant
  allowDelete : simpleSchema.DefaultBoolean()
  creator     : simpleSchema.DefaultCreator
  version     : {type: simpleSchema.Version}

  details                   : type: [Object], defaultValue: []
  'details.$._id'           : simpleSchema.UniqueId
  'details.$.product'       : type: String
  'details.$.productUnit'   : type: String
  'details.$.salePrice'     : {type: Number, min: 0}
  'details.$.importPrice'   : {type: Number, min: 0}

Schema.add 'priceBooks', "PriceBook", class PriceBook
  @transform: (doc) ->

  @insert: (name) -> Schema.priceBooks.insert {name: name} if name

  @insertDetailByProductUnit: (productUnitId) ->
    if userId = Meteor.userId()
      merchantId = Meteor.users.findOne(userId).profiles.merchant
      product = Schema.products.findOne({'units._id': productUnitId, merchant: merchantId})
      productUnit = _.findWhere(product.units, {_id: productUnitId})
      priceBook = Schema.priceBooks.findOne({priceBookType: 0, merchant: merchantId})
      if productUnit and priceBook
        productUnitExisted = true
        ((productUnitExisted = false; break) if detail.productUnit is productUnit._id) for detail in priceBook.details
        if productUnitExisted
          updateOption = $push:{details:{product: product._id, productUnit: productUnit._id, salePrice: 0, importPrice:0}}
          Schema.priceBooks.update priceBook._id, updateOption

  @removeDetailByProductUnit: (productUnitId) ->
    if userId = Meteor.userId()
      merchantId = Meteor.users.findOne(userId).profiles.merchant
      product = Schema.products.findOne({'units._id': productUnitId, merchant: merchantId})
      priceBookLists = Schema.priceBooks.find({'details.productUnit': productUnitId, priceBookType: 0, merchant: merchantId}).fetch()

      if !product and priceBookLists
        for priceBook in priceBookLists
          ((removeIndex = i; break) if instance.productUnit is productUnitId) for instance, i in priceBook.details
          removeUnitQuery = { $pull:{ details: priceBook.details[removeIndex] } }
          Schema.priceBooks.update priceBook._id, removeUnitQuery

  @nameIsExisted: (name, merchant = null) ->
    existedQuery = {name: name, merchant: merchant ? Meteor.user().profiles.merchant}
    Schema.priceBooks.findOne(existedQuery)

  @setSession: (priceBookId) ->
    Meteor.users.update(Meteor.userId(), {$set: {'sessions.currentPriceBook': priceBookId}})