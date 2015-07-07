Enums = Apps.Merchant.Enums
simpleSchema.products = new SimpleSchema
  name            : {type: String   ,unique  : true, index: 1}
  nameSearch      : simpleSchema.searchSource('name')
  description     : {type: String ,optional: true}
  image           : {type: String ,optional: true}
  group           : {type: String ,optional: true}
  inventoryInitial: simpleSchema.DefaultBoolean(false)


  status      : {type: Number , defaultValue: Enums.getValue('ProductStatuses', 'initialize')}
  merchant    : simpleSchema.DefaultMerchant
  allowDelete : simpleSchema.DefaultBoolean()
  creator     : simpleSchema.DefaultCreator
  version     : {type: simpleSchema.Version}

  units                : type: [Object], optional: true
  'units.$._id'        : type: String
  'units.$.barcode'    : simpleSchema.Barcode
  'units.$.name'       : type: String
  'units.$.conversion' : type: Number
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
    doc.unitName = -> doc.units[0].name if doc.units.length > 0

    doc.getPrice = (productUnitId, ownerId, priceType = 'sale') ->
      priceFound = undefined; merchantId = Merchant.getId()
      if productUnitId is undefined and ownerId is undefined
        for unit in @units
          if unit.isBase
            priceFound = 0
            if priceBookBasic = Schema.priceBooks.findOne({priceBookType: 0, merchant: merchantId})
              priceFound = findPrice(priceBookBasic._id, unit.priceBooks, priceType)
      else
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

    doc.unitCreate = (name, conversion = 1)->
      unitNameIsExisted = false; conversion = Number(conversion)
      (unitNameIsExisted = true if unit.name is name) for unit in @units
      return if isNaN(conversion)

      unless unitNameIsExisted
        priceBookBasic = Schema.priceBooks.findOne({priceBookType: 0, merchant: Merchant.getId()})
        for unit in @units
          if unit.isBase
            salePrice   = findPrice(priceBookBasic._id, unit.priceBooks, 'sale')
            importPrice = findPrice(priceBookBasic._id, unit.priceBooks, 'import')

        priceBook = [{
          priceBook: priceBookBasic._id
          basicSale  : salePrice * conversion
          salePrice  : salePrice * conversion
          basicImport: importPrice * conversion
          importPrice: importPrice * conversion
          discountSalePrice  : 0
          updateSalePriceAt  : new Date()
          discountImportPrice: 0
          updateImportPriceAt: new Date()
        }]

        productUnitId = Random.id()
        productUnit =
          _id       : productUnitId
          name      : name
          conversion: conversion
          priceBooks: priceBook
          quality   : {}

        if Schema.products.update(@_id, {$push: { units: productUnit }})
          PriceBook.addProductUnit(productUnitId)
          return true


    doc.unitUpdate = (unitId, option, callback) ->
      unitNameIsNotExist = true
      barcodeIsNotExit   = true

      priceBookBasic = Schema.priceBooks.findOne({priceBookType: 0, merchant: Session.get('myProfile').merchant})
      for instance, i in @units
        unitNameIsNotExist = false if option.name and instance.name is option.name
        if instance._id is unitId
          updateUnitIndex = i
          updateInstance = instance

        if instance.isBase
          for priceBook, index in instance.priceBooks
            if priceBook.priceBook is priceBookBasic._id
              priceBookBasicIndex = index
              unitPriceBookBasic  = priceBook


      unitUpdateQuery = $set:{}
      if option.name and unitNameIsNotExist
        unitUpdateQuery.$set["units.#{updateUnitIndex}.name"] = option.name

      if option.barcode and barcodeIsNotExit
        unitUpdateQuery.$set["units.#{updateUnitIndex}.barcode"] = option.barcode

      if option.conversion
        if updateInstance.allowDelete and updateInstance.isBase is false and option.conversion and option.conversion >= 1
          unitUpdateQuery.$set["units.#{updateUnitIndex}.conversion"] = option.conversion

          for priceBook, priceBookIndex in updateInstance.priceBooks
            console.log unitPriceBookBasic

            priceBookQuery = "units.#{updateUnitIndex}.priceBooks.#{priceBookIndex}"
            unitUpdateQuery.$set["#{priceBookQuery}.basicSale"]         = unitPriceBookBasic.salePrice * option.conversion
            unitUpdateQuery.$set["#{priceBookQuery}.salePrice"]         = unitPriceBookBasic.salePrice * option.conversion
            unitUpdateQuery.$set["#{priceBookQuery}.discountSalePrice"] = 0
            unitUpdateQuery.$set["#{priceBookQuery}.updateSalePriceAt"] = new Date()

            unitUpdateQuery.$set["#{priceBookQuery}.basicImport"]         = unitPriceBookBasic.importPrice * option.conversion
            unitUpdateQuery.$set["#{priceBookQuery}.importPrice"]         = unitPriceBookBasic.importPrice * option.conversion
            unitUpdateQuery.$set["#{priceBookQuery}.discountImportPrice"] = 0
            unitUpdateQuery.$set["#{priceBookQuery}.updateImportPriceAt"] = new Date()


      else
        if option.importPrice and option.importPrice >= 0
          if updateInstance.isBase
            for unit, unitIndex in @units
              for priceBook, priceBookIndex in unit.priceBooks
                priceBookQuery = "units.#{unitIndex}.priceBooks.#{priceBookIndex}"
                unitUpdateQuery.$set["#{priceBookQuery}.basicImport"]         = option.importPrice * unit.conversion
                unitUpdateQuery.$set["#{priceBookQuery}.importPrice"]         = option.importPrice * unit.conversion
                unitUpdateQuery.$set["#{priceBookQuery}.discountImportPrice"] = 0
                unitUpdateQuery.$set["#{priceBookQuery}.updateImportPriceAt"] = new Date()
          else
            for priceBook, priceBookIndex in updateInstance.priceBooks
              priceBookQuery = "units.#{updateUnitIndex}.priceBooks.#{priceBookIndex}"
              unitUpdateQuery.$set["#{priceBookQuery}.importPrice"]         = option.importPrice
              unitUpdateQuery.$set["#{priceBookQuery}.discountImportPrice"] = priceBook.basicImport - option.importPrice
              unitUpdateQuery.$set["#{priceBookQuery}.updateImportPriceAt"] = new Date()

        if option.salePrice and option.salePrice >= 0
          if updateInstance.isBase
            for unit, unitIndex in @units
              for priceBook, priceBookIndex in unit.priceBooks
                priceBookQuery = "units.#{unitIndex}.priceBooks.#{priceBookIndex}"
                unitUpdateQuery.$set["#{priceBookQuery}.basicSale"]         = option.salePrice * unit.conversion
                unitUpdateQuery.$set["#{priceBookQuery}.salePrice"]         = option.salePrice * unit.conversion
                unitUpdateQuery.$set["#{priceBookQuery}.discountSalePrice"] = 0
                unitUpdateQuery.$set["#{priceBookQuery}.updateSalePriceAt"] = new Date()
          else
            for priceBook, priceBookIndex in updateInstance.priceBooks
              priceBookQuery = "units.#{updateUnitIndex}.priceBooks.#{priceBookIndex}"
              unitUpdateQuery.$set["#{priceBookQuery}.salePrice"]         = option.salePrice
              unitUpdateQuery.$set["#{priceBookQuery}.discountSalePrice"] = priceBook.basicImport - option.importPrice
              unitUpdateQuery.$set["#{priceBookQuery}.updateSalePriceAt"] = new Date()

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
    option.units = [{_id: productUnitId, name: 'Chai', allowDelete: false, isBase: true, priceBooks: priceBook, quality: {}}]

    if newProductId = Schema.products.insert option
      PriceBook.addProductUnit(productUnitId); Product.setSession(newProductId)
    newProductId

  @nameIsExisted: (name, merchant = null) ->
    existedQuery = {name: name, merchant: merchant ? Meteor.user().profiles.merchant}
    Schema.priceBooks.findOne(existedQuery)

  @setSession: (currentProductId) ->
    Meteor.subscribe('productManagementCurrentProductData', @_id) if Meteor.isClient
    Meteor.users.update(Meteor.userId(), {$set: {'sessions.currentProduct': currentProductId}})
