simpleSchema.products = new SimpleSchema
  name        : {type: String   ,unique  : true, index: 1}
  description : {type: String   ,optional: true}
  image       : {type: String   ,optional: true}
  groups      : {type: [String] ,defaultValue: []}

  merchant    : simpleSchema.DefaultMerchant
  allowDelete : simpleSchema.DefaultBoolean()
  creator     : simpleSchema.DefaultCreator
  version     : {type: simpleSchema.Version}

  units: type: [Object], optional: true
  'units.$._id'        : type: String
  'units.$.barcode'    : simpleSchema.Barcode
  'units.$.name'       : simpleSchema.OptionalString
  'units.$.conversion' : simpleSchema.DefaultNumber(1)
  'units.$.isBase'     : simpleSchema.DefaultBoolean(false)
  'units.$.allowDelete': simpleSchema.DefaultBoolean()
  'units.$.createdAt'  : simpleSchema.DefaultCreatedAt

  'units.$.importPrice': simpleSchema.DefaultNumber()
  'units.$.salePrice'  : simpleSchema.DefaultNumber()

  qualities                        : type: [Object], optional: true
  'qualities.$.upperGapQuality'    : simpleSchema.DefaultNumber()
  'qualities.$.availableQuality'   : simpleSchema.DefaultNumber()
  'qualities.$.inOderQuality'      : simpleSchema.DefaultNumber()
  'qualities.$.inStockQuality'     : simpleSchema.DefaultNumber()
  'qualities.$.saleQuality'        : simpleSchema.DefaultNumber()
  'qualities.$.returnSaleQuality'  : simpleSchema.DefaultNumber()
  'qualities.$.importQuality'      : simpleSchema.DefaultNumber()
  'qualities.$.returnImportQuality': simpleSchema.DefaultNumber()

Schema.add 'products', "Product", class Product
  @transform: (doc) ->
    doc.unitName = doc.units[0].name if doc.units.length > 0
    doc.unitCreate = (name = 'New')->
      productUnitId = Random.id()
      if Schema.products.update(@_id, {$push: { units: {_id: productUnitId} }})
        PriceBook.insertDetailByProductUnit(productUnitId)

    doc.unitUpdate = (unitId, option, callback) ->
      unitNameIsNotExist = true
      barcodeIsNotExit   = true

      for instance, i in @units
        unitNameIsNotExist = false if option.name and instance.name is option.name
        if instance._id is unitId
          updateIndex = i
          updateInstance = instance


      unitUpdateQuery = $set:{}
      if option.name and unitNameIsNotExist
        unitUpdateQuery.$set["units.#{updateIndex}.name"] = option.name

      if option.barcode and barcodeIsNotExit
        unitUpdateQuery.$set["units.#{updateIndex}.barcode"] = option.barcode

      if option.importPrice and option.importPrice >= 0
        unitUpdateQuery.$set["units.#{updateIndex}.importPrice"] = option.importPrice

      if option.salePrice and option.salePrice >= 0
        unitUpdateQuery.$set["units.#{updateIndex}.salePrice"] = option.salePrice

      if updateInstance.allowDelete and option.conversion and option.conversion >= 1
        unitUpdateQuery.$set["units.#{updateIndex}.conversion"] = option.conversion

      Schema.products.update(@_id, unitUpdateQuery, callback) unless _.isEmpty(unitUpdateQuery.$set)

    doc.unitRemove = (unitId, callback)->
      for instance, i in @units
        if instance._id is unitId
          removeIndex = i
          removeInstance = instance
          break

      if removeInstance and removeInstance.allowDelete and !removeInstance.isBase
        removeUnitQuery = { $pull:{ units: @units[removeIndex] } }
        if Schema.products.update(@_id, removeUnitQuery, callback) is 1
          PriceBook.removeDetailByProductUnit(removeInstance._id)

    doc.remove = (callback)->
      if @allowDelete
        Schema.products.remove @_id, callback

  @insert: (option = {})->
    productUnitId = Random.id()
    option.units = [{_id: productUnitId, name: 'MacDinh', allowDelete: false, isBase: true}]
    if newProductId = Schema.products.insert option
      PriceBook.insertDetailByProductUnit(productUnitId); Product.setSession(newProductId)
    newProductId

  @nameIsExisted: (name, merchant = null) ->
    existedQuery = {name: name, merchant: merchant ? Meteor.user().profiles.merchant}
    Schema.priceBooks.findOne(existedQuery)

  @setSession: (currentProductId) ->
    Meteor.subscribe('productManagementCurrentProductData', @_id) if Meteor.isClient
    Meteor.users.update(Meteor.userId(), {$set: {'sessions.currentProduct': currentProductId}})
