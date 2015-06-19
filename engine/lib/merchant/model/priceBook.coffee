simpleSchema.priceBooks = new SimpleSchema
  name          : {type: String ,unique  : true, index: 1}
  description   : {type: String ,optional: true}
  priceBookType : {type: Number ,defaultValue: 1}
  productUnits  : {type: [String] ,optional: true}
  owners        : {type: [String] ,optional: true}

  merchant    : simpleSchema.DefaultMerchant
  allowDelete : simpleSchema.DefaultBoolean()
  creator     : simpleSchema.DefaultCreator
  version     : {type: simpleSchema.Version}

Schema.add 'priceBooks', "PriceBook", class PriceBook
  @transform: (doc) ->
    doc.updateProductUnitPrice = (productUnitId, salePrice, importPrice, callback) ->
      priceBookId = @_id; priceBookType = @priceBookType; priceBookIndex = undefined; productUnitIndex = undefined
      product = Schema.products.findOne({'units._id': productUnitId, merchant: Session.get('merchant')._id})

      for unit, i in product.units
        if unit._id is productUnitId
          productUnitIndex = i

          for item, index in unit.priceBooks
            priceBookIndex = index if item.priceBook is priceBookId

      console.log salePrice, importPrice, productUnitIndex, priceBookIndex
      if productUnitIndex >= 0
        console.log 'ok'
        if priceBookIndex isnt undefined
          console.log 'update'

          unitUpdateQuery = $set:{}

          if _.contains([0, 1, 2], priceBookType)
            if salePrice and salePrice >= 0
              unitUpdateQuery.$set["units.#{productUnitIndex}.priceBooks.#{priceBookIndex}.salePrice"] = salePrice

          if _.contains([0, 3, 4], priceBookType)
            if importPrice and importPrice >= 0
              unitUpdateQuery.$set["units.#{productUnitIndex}.priceBooks.#{priceBookIndex}.importPrice"] = importPrice

          Schema.products.update(product._id, unitUpdateQuery, callback) unless _.isEmpty(unitUpdateQuery.$set)

        else
          console.log 'insert'
          unitUpdateQuery = $push: {}; priceBook = {priceBook: priceBookId}
          if _.contains([1, 2], priceBookType)
            priceBook.salePrice = salePrice if salePrice and salePrice >= 0
            unitUpdateQuery.$push["units.#{productUnitIndex}.priceBooks"] = priceBook

          if _.contains([3, 4], priceBookType)
            priceBook.importPrice = importPrice if importPrice and importPrice >= 0
            unitUpdateQuery.$push["units.#{productUnitIndex}.priceBooks"] = priceBook

          console.log unitUpdateQuery
          Schema.products.update(product._id, unitUpdateQuery, callback) unless _.isEmpty(unitUpdateQuery.$push)



  @insert: (name) -> Schema.priceBooks.insert {name: name} if name

  @removeProductUnit: (productUnitId)->
    if userId = Meteor.userId()
      merchantId = Meteor.users.findOne(userId).profiles.merchant
      product = Schema.products.findOne({'units._id': productUnitId, merchant: merchantId})
      priceBook = Schema.priceBooks.findOne({productUnits: productUnitId, priceBookType: 0, merchant: merchantId})
      if priceBook and !product
        Schema.priceBooks.update priceBook._id, {$pull: {productUnits: productUnitId}}

  @addProductUnit: (productUnitId)->
    if userId = Meteor.userId()
      merchantId = Meteor.users.findOne(userId).profiles.merchant
      product = Schema.products.findOne({'units._id': productUnitId, merchant: merchantId})
      priceBook = Schema.priceBooks.findOne({productUnits: {$ne: productUnitId}, priceBookType: 0, merchant: merchantId})
      if priceBook and product
        Schema.priceBooks.update priceBook._id, {$addToSet: {productUnits: productUnitId}}

  @nameIsExisted: (name, merchant = null) ->
    existedQuery = {name: name, merchant: merchant ? Meteor.user().profiles.merchant}
    Schema.priceBooks.findOne(existedQuery)

  @setSession: (priceBookId) ->
    Meteor.users.update(Meteor.userId(), {$set: {'sessions.currentPriceBook': priceBookId}})

#  @insertDetailByProductUnit: (productUnitId) ->
#    if userId = Meteor.userId()
#      merchantId = Meteor.users.findOne(userId).profiles.merchant
#      product = Schema.products.findOne({'units._id': productUnitId, merchant: merchantId})
#      productUnit = _.findWhere(product.units, {_id: productUnitId})
#      priceBook = Schema.priceBooks.findOne({priceBookType: 0, merchant: merchantId})
#      if productUnit and priceBook
#        productUnitExisted = true
#        ((productUnitExisted = false; break) if detail.productUnit is productUnit._id) for detail in priceBook.details
#        if productUnitExisted
#          updateOption = $push:{details:{product: product._id, productUnit: productUnit._id, salePrice: 0, importPrice:0}}
#          Schema.priceBooks.update priceBook._id, updateOption
#
#  @removeDetailByProductUnit: (productUnitId) ->
#    if userId = Meteor.userId()
#      merchantId = Meteor.users.findOne(userId).profiles.merchant
#      product = Schema.products.findOne({'units._id': productUnitId, merchant: merchantId})
#      priceBookLists = Schema.priceBooks.find({'details.productUnit': productUnitId, priceBookType: 0, merchant: merchantId}).fetch()
#
#      if !product and priceBookLists
#        for priceBook in priceBookLists
#          ((removeIndex = i; break) if instance.productUnit is productUnitId) for instance, i in priceBook.details
#          removeUnitQuery = { $pull:{ details: priceBook.details[removeIndex] } }
#          Schema.priceBooks.update priceBook._id, removeUnitQuery
