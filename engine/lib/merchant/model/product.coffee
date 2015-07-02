Enums = Apps.Merchant.Enums
simpleSchema.products = new SimpleSchema
  name        : {type: String   ,unique  : true, index: 1}
  nameSearch  : simpleSchema.searchSource('name')
  description : {type: String ,optional: true}
  image       : {type: String ,optional: true}
  group       : {type: String ,optional: true}

  merchant    : simpleSchema.DefaultMerchant
  allowDelete : simpleSchema.DefaultBoolean()
  creator     : simpleSchema.DefaultCreator
  version     : {type: simpleSchema.Version}

  units                : type: [Object], optional: true
  'units.$._id'        : type: String
  'units.$.barcode'    : simpleSchema.Barcode
  'units.$.name'       : simpleSchema.OptionalString
  'units.$.conversion' : simpleSchema.DefaultNumber(1)
  'units.$.isBase'     : simpleSchema.DefaultBoolean(false)
  'units.$.allowDelete': simpleSchema.DefaultBoolean()
  'units.$.createdAt'  : simpleSchema.DefaultCreatedAt

  'units.$.priceBooks'                      : type: [Object], optional: true
  'units.$.priceBooks.$.priceBook'          : type: String

  'units.$.priceBooks.$.basicSale'          : type: Number, optional: true
  'units.$.priceBooks.$.salePrice'          : type: Number, optional: true
  'units.$.priceBooks.$.discountSalePrice'  : type: Number, optional: true
  'units.$.priceBooks.$.updateSalePriceAt'  : type: Date  , optional: true

  'units.$.priceBooks.$.basicImport'         : type: Number, optional: true
  'units.$.priceBooks.$.importPrice'        : type: Number, optional: true
  'units.$.priceBooks.$.discountImportPrice': type: Number, optional: true
  'units.$.priceBooks.$.updateImportPriceAt': type: Date  , optional: true

  'units.$.quality'                       : type: Object, optional: true
  'units.$.quality.$.upperGapQuality'     : simpleSchema.DefaultNumber()
  'units.$.quality.$.inStockQuality'      : simpleSchema.DefaultNumber()
  'units.$.quality.$.inOderQuality'       : simpleSchema.DefaultNumber()
  'units.$.quality.$.availableQuality'    : simpleSchema.DefaultNumber()
  'units.$.quality.$.saleQuality'         : simpleSchema.DefaultNumber()
  'units.$.quality.$.returnSaleQuality'   : simpleSchema.DefaultNumber()
  'units.$.quality.$.importQuality'       : simpleSchema.DefaultNumber()
  'units.$.quality.$.returnImportQuality' : simpleSchema.DefaultNumber()

  qualities                        : type: [Object], defaultValue: [{}]
  'qualities.$.upperGapQuality'    : simpleSchema.DefaultNumber()
  'qualities.$.availableQuality'   : simpleSchema.DefaultNumber()
  'qualities.$.inOderQuality'      : simpleSchema.DefaultNumber()
  'qualities.$.inStockQuality'     : simpleSchema.DefaultNumber()
  'qualities.$.saleQuality'        : simpleSchema.DefaultNumber()
  'qualities.$.returnSaleQuality'  : simpleSchema.DefaultNumber()
  'qualities.$.importQuality'      : simpleSchema.DefaultNumber()
  'qualities.$.returnImportQuality': simpleSchema.DefaultNumber()

findPrice = (priceBookId, priceBookList, priceType = 'sale') ->
  if priceType is 'sale'
    for priceBook in priceBookList
      return priceBook.salePrice if priceBook.priceBook is priceBookId
    return undefined
  else if priceType is 'import'
    for priceBook in priceBookList
      return priceBook.importPrice if priceBook.priceBook is priceBookId
    return undefined

Schema.add 'products', "Product", class Product
  @transform: (doc) ->
    doc.unitName = doc.units[0].name if doc.units.length > 0

    doc.getPrice = (productUnitId, ownerId, priceType = 'sale') ->
      priceFound = undefined; merchantId = Session.get('merchant')._id
      for unit in @units
        if unit._id is productUnitId
          if priceType is 'sale'
            buyer = Schema.customers.findOne({_id: ownerId, merchant: merchantId})
            if buyer
              priceBookOfBuyer = PriceBook.findOneByUnitAndBuyer(buyer._id, merchantId)
              priceBookOfBuyerGroup = PriceBook.findOneByUnitAndBuyerGroup(buyer.group, merchantId)
              priceFound = findPrice(priceBookOfBuyer._id, unit.priceBooks, priceType) if priceBookOfBuyer
              priceFound = findPrice(priceBookOfBuyerGroup._id, unit.priceBooks, priceType) if priceBookOfBuyerGroup and priceFound is undefined
            priceFound = findPrice(Session.get('priceBookBasic')._id, unit.priceBooks, priceType) if priceFound is undefined

          else if priceType is 'import'
            provider = Schema.providers.findOne({_id: ownerId, merchant: Session.get('merchant')._id})
            if provider
              priceBookOfProvider = PriceBook.findOneByUnitAndProvider(provider._id, merchantId)
              priceBookOfProviderGroup = PriceBook.findOneByUnitAndProviderGroup(provider.group, merchantId)
              priceFound = findPrice(priceBookOfProvider._id, unit.priceBooks, priceType) if priceBookOfProvider
              priceFound = findPrice(priceBookOfProviderGroup._id, unit.priceBooks, priceType) if priceBookOfProviderGroup and priceFound is undefined
            priceFound = findPrice(Session.get('priceBookBasic')._id, unit.priceBooks, priceType) if priceFound is undefined
          return priceFound

    doc.unitCreate = (name = 'New')->
      priceBookBasic = Schema.priceBooks.findOne({priceBookType: 0, merchant: Session.get('myProfile').merchant})
      priceBook = [{priceBook: priceBookBasic._id, salePrice: 0, importPrice: 0}]

      productUnitId = Random.id()
      if Schema.products.update(@_id, {$push: { units: {_id: productUnitId, priceBooks: priceBook , quality: {}} }})
        PriceBook.addProductUnit(productUnitId)

    doc.unitUpdate = (unitId, option, callback) ->
      unitNameIsNotExist = true
      barcodeIsNotExit   = true

      for instance, i in @units
        unitNameIsNotExist = false if option.name and instance.name is option.name
        if instance._id is unitId
          updateIndex = i
          updateInstance = instance

          priceBookBasic = Schema.priceBooks.findOne({priceBookType: 0, merchant: Session.get('myProfile').merchant})
          for priceBook, index in instance.priceBooks
            updatePriceBook = index if priceBook.priceBook is priceBookBasic._id


      unitUpdateQuery = $set:{}
      if option.name and unitNameIsNotExist
        unitUpdateQuery.$set["units.#{updateIndex}.name"] = option.name

      if option.barcode and barcodeIsNotExit
        unitUpdateQuery.$set["units.#{updateIndex}.barcode"] = option.barcode

      if option.importPrice and option.importPrice >= 0
        unitUpdateQuery.$set["units.#{updateIndex}.priceBooks.#{updatePriceBook}.importPrice"] = option.importPrice

      if option.salePrice and option.salePrice >= 0
        unitUpdateQuery.$set["units.#{updateIndex}.priceBooks.#{updatePriceBook}.salePrice"] = option.salePrice

      if updateInstance.allowDelete and option.conversion and option.conversion >= 1
        unitUpdateQuery.$set["units.#{updateIndex}.conversion"] = option.conversion

      console.log unitUpdateQuery
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
          PriceBook.reUpdateByRemoveProductUnit(removeInstance._id)

    doc.remove = (callback)->
      if @allowDelete
        if Schema.products.remove @_id, callback
          PriceBook.reUpdateByRemoveProductUnit(productUnit._id) for productUnit in @units

  @insert: (option = {})->
    priceBookBasic = Schema.priceBooks.findOne({priceBookType: 0, merchant: Session.get('myProfile').merchant})
    priceBook = [{priceBook: priceBookBasic._id, salePrice: 0, importPrice: 0}]

    productUnitId = Random.id()
    option.units = [{_id: productUnitId, name: 'MacDinh', allowDelete: false, isBase: true, priceBooks: priceBook, quality: {}}]

    if newProductId = Schema.products.insert option
      PriceBook.addProductUnit(productUnitId); Product.setSession(newProductId)
    newProductId

  @nameIsExisted: (name, merchant = null) ->
    existedQuery = {name: name, merchant: merchant ? Meteor.user().profiles.merchant}
    Schema.priceBooks.findOne(existedQuery)

  @setSession: (currentProductId) ->
    Meteor.subscribe('productManagementCurrentProductData', @_id) if Meteor.isClient
    Meteor.users.update(Meteor.userId(), {$set: {'sessions.currentProduct': currentProductId}})
