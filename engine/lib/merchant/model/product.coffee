Enums = Apps.Merchant.Enums
simpleSchema.products = new SimpleSchema
  name        : type: String , unique  : true, index: 1
  avatar      : type: String , optional: true
  description : type: String , optional: true
  group       : type: String , optional: true
  status      : type: Number , defaultValue: Enums.getValue('ProductStatuses', 'initialize')
  lastExpire  : type: Date   , optional: true
  nameSearch  : simpleSchema.searchSource('name')
  inventoryInitial: type: Boolean , defaultValue: false


  merchant    : simpleSchema.DefaultMerchant
  allowDelete : simpleSchema.DefaultBoolean()
  creator     : simpleSchema.DefaultCreator
  version     : {type: simpleSchema.Version}

  #bang gia
  priceBooks                 : type: [Object]
  'priceBooks.$._id'         : type: String
  'priceBooks.$.basicSale'   : type: Number, optional: true
  'priceBooks.$.salePrice'   : type: Number, optional: true
  'priceBooks.$.basicImport' : type: Number, optional: true
  'priceBooks.$.importPrice' : type: Number, optional: true


  #doanh thu cua ban hang, nhap hang, tra hang
  quantityTurnover                         : type: [Object]
  'quantityRevenues.$.warehouseId'         : type: String, optional: true
  'quantityRevenues.$.saleTurnover'        : type: Number
  'quantityRevenues.$.importTurnover'      : type: Number
  'quantityRevenues.$.returnSaleTurnover'  : type: Number
  'quantityRevenues.$.returnImportTurnover': type: Number

  #so luong san pham trong kho
  quantities                         : type: [Object]
  'quantities.$.warehouseId'         : type: String, optional: true
  'quantities.$.normsQuantity'       : type: Number
  'quantities.$.availableQuantity'   : type: Number
  'quantities.$.inOderQuantity'      : type: Number

  'quantities.$.inStockQuantity'     : type: Number
  'quantities.$.saleQuantity'        : type: Number
  'quantities.$.importQuantity'      : type: Number
  'quantities.$.returnSaleQuantity'  : type: Number
  'quantities.$.returnImportQuantity': type: Number

  #don vi tinh
  units                : type: [Object]
  'units.$._id'        : type: String
  'units.$.barcode'    : simpleSchema.Barcode
  'units.$.name'       : type: String
  'units.$.conversion' : type: Number
  'units.$.isBase'     : type: Boolean, defaultValue: false
  'units.$.allowDelete': type: Boolean, defaultValue: true
  'units.$.lastExpire' : type: Date   , optional: true
  'units.$.createdAt'  : simpleSchema.DefaultCreatedAt



findPrice = (priceBookId, priceBookList, priceType = 'sale') ->
  if priceType is 'sale'
    for priceBook in priceBookList
      return priceBook.salePrice if priceBook._id is priceBookId
    return undefined

  else if priceType is 'import'
    for priceBook in priceBookList
      return priceBook.importPrice if priceBook._id is priceBookId
    return undefined

Schema.add 'products', "Product", class Product
  @transform: (doc) ->
    doc.hasAvatar   = -> if doc.avatar then '' else 'missing'
    doc.avatarUrl   = -> if doc.avatar then AvatarImages.findOne(doc.avatar)?.url() else undefined

    if doc.units?.length > 0
      doc.unitName    = -> doc.units[0].name
      doc.basicUnit   = -> doc.units[0]
      doc.basicUnitId = -> doc.units[0]._id

    if doc.quantities?.length > 0
      doc.allQuantity   = doc.quantities[0].inStockQuantity
      doc.normsQuantity = doc.quantities[0].normsQuantity
      doc.normsCount    = doc.quantities[0].normsQuantity - doc.quantities[0].inStockQuantity


    doc.getPrice = (ownerId, priceType = 'sale') ->
      priceFound = undefined; merchantId = Merchant.getId()
      if ownerId is undefined
        if priceBookBasic = Schema.priceBooks.findOne({priceBookType: 0, merchant: merchantId})
          priceFound = findPrice(priceBookBasic._id, doc.priceBooks, priceType) ? 0

      else
        if priceType is 'sale'
          buyer = Schema.customers.findOne({_id: ownerId, merchant: merchantId})
          if buyer
            priceBookOfBuyer = PriceBook.findOneByUnitAndBuyer(buyer._id, merchantId)
            priceBookOfBuyerGroup = PriceBook.findOneByUnitAndBuyerGroup(buyer.group, merchantId)
            priceFound = findPrice(priceBookOfBuyer._id, doc.priceBooks, priceType) if priceBookOfBuyer
            priceFound = findPrice(priceBookOfBuyerGroup._id, doc.priceBooks, priceType) if priceBookOfBuyerGroup and priceFound is undefined
          priceFound = findPrice(Session.get('priceBookBasic')._id, doc.priceBooks, priceType) if priceFound is undefined

        else if priceType is 'import'
          provider = Schema.providers.findOne({_id: ownerId, merchant: Session.get('merchant')._id})
          if provider
            priceBookOfProvider = PriceBook.findOneByUnitAndProvider(provider._id, merchantId)
            priceBookOfProviderGroup = PriceBook.findOneByUnitAndProviderGroup(provider.group, merchantId)
            priceFound = findPrice(priceBookOfProvider._id, doc.priceBooks, priceType) if priceBookOfProvider
            priceFound = findPrice(priceBookOfProviderGroup._id, doc.priceBooks, priceType) if priceBookOfProviderGroup and priceFound is undefined
          priceFound = findPrice(Session.get('priceBookBasic')._id, doc.priceBooks, priceType) if priceFound is undefined
      return priceFound

    doc.unitCreate = (name, conversion = 1)->
      unitNameIsExisted = false; conversion = Number(conversion)
      (unitNameIsExisted = true if unit.name is name) for unit in @units
      return if isNaN(conversion)

      unless unitNameIsExisted
        productUnit =
          _id         : Random.id()
          name        : name
          conversion  : conversion
          isBase      : false
          allowDelete : true

        Schema.products.update(@_id, {$push: { units: productUnit }})

    #cap nhat unit
    doc.unitUpdate = (unitId, option) ->
      unitNameIsNotExist = true
      barcodeIsNotExit   = true


      for instance, i in @units
        unitNameIsNotExist = false if option.name and instance.name is option.name
        (updateUnitIndex = i; updateInstance = instance; break) if instance._id is unitId


      if updateInstance
        unitUpdateQuery = $set:{}
        if option.name and unitNameIsNotExist
          unitUpdateQuery.$set["units.#{updateUnitIndex}.name"] = option.name


        if option.barcode and barcodeIsNotExit
          unitUpdateQuery.$set["units.#{updateUnitIndex}.barcode"] = option.barcode


        if option.conversion
          if updateInstance.allowDelete and updateInstance.isBase is false and option.conversion and option.conversion >= 1
            unitUpdateQuery.$set["units.#{updateUnitIndex}.conversion"] = option.conversion


        if updateInstance.isBase and option.importPrice and option.importPrice >= 0
          for priceBook, priceBookIndex in doc.priceBooks
            priceBookQuery = "priceBooks.#{priceBookIndex}"
            unitUpdateQuery.$set["#{priceBookQuery}.basicImport"] = option.importPrice
            unitUpdateQuery.$set["#{priceBookQuery}.importPrice"] = option.importPrice


        if updateInstance.isBase and option.salePrice and option.salePrice >= 0
          for priceBook, priceBookIndex in doc.priceBooks
            priceBookQuery = "priceBooks.#{priceBookIndex}"
            unitUpdateQuery.$set["#{priceBookQuery}.basicSale"] = option.salePrice
            unitUpdateQuery.$set["#{priceBookQuery}.salePrice"] = option.salePrice


        Schema.products.update(@_id, unitUpdateQuery) unless _.isEmpty(unitUpdateQuery.$set)

    doc.unitDenyDelete = (unitId)->
      ((updateUnitIndex = index) if instance._id is unitId) for instance, index in @units
      unitUpdateQuery = $set:{}
      unitUpdateQuery.$set["units.#{updateUnitIndex}.allowDelete"] = false if updateUnitIndex
      Schema.products.update(@_id, unitUpdateQuery) unless _.isEmpty(unitUpdateQuery.$set)

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
          PriceBook.reUpdateByRemoveProduct(@_id)
          Schema.productGroups.update @group, $pull: {products: @_id }


    doc.productConfirm = ->
      if @status is Enums.getValue('ProductStatuses', 'initialize')
        Schema.products.update @_id, $set:{status: Enums.getValue('ProductStatuses', 'confirmed')}

    doc.submitInventory = (inventoryDetails)->
      if User.hasManagerRoles() and doc.inventoryInitial is false
        for detail in inventoryDetails
          if detail._id is doc.basicUnitId()
            importDetail = {_id: detail._id, quantity: detail.quality , expireDay: detail.expriceDay, product: doc._id}
            break

        console.log importDetail
        if importDetail
          Meteor.call 'productInventory', doc._id, importDetail, (error, result) -> console.log error, result

  @insert: (option = {})->
    if priceBookBasic   = Schema.priceBooks.findOne({priceBookType: 0, merchant: Merchant.getId()})
      option.units      = generateUnit(Random.id())
      option.priceBooks = generatePriceBook(priceBookBasic._id)
      option.quantities = generateQuantity()
      option.quantityTurnover = generateTurnover()

      if newProductId = Schema.products.insert option
        Product.setSession(newProductId)
        PriceBook.addProduct(newProductId)
        ProductGroup.addProduct(newProductId)
      newProductId

  @nameIsExisted: (name, merchant = null) ->
    existedQuery = {name: name, merchant: merchant ? Meteor.user().profile.merchant}
    Schema.priceBooks.findOne(existedQuery)

  @setSession: (currentProductId) ->
    Meteor.users.update(Meteor.userId(), {$set: {'sessions.currentProduct': currentProductId}})

generateQuantity = (warehouseId)->
  quantity = [{
    normsQuantity     : 0
    availableQuantity    : 0
    inOderQuantity       : 0
    inStockQuantity      : 0
    saleQuantity         : 0
    importQuantity       : 0
    returnSaleQuantity   : 0
    returnImportQuantity : 0
  }]
  quantity.warehouseId = warehouseId if warehouseId
  quantity

generateTurnover = (warehouseId)->
  turnover = [{
    saleTurnover        : 0
    importTurnover      : 0
    returnSaleTurnover  : 0
    returnImportTurnover: 0
  }]
  turnover.warehouseId = warehouseId if warehouseId
  turnover


generatePriceBook = (priceBookBasicId)->
  [{ _id: priceBookBasicId, basicSale: 0, salePrice: 0, basicImport: 0, importPrice: 0 }]

generateUnit = (productUnitId, name = 'Chai', isBase = true, conversion = 1)->
  [{ _id: productUnitId, name: name, allowDelete: !isBase, isBase: isBase, conversion: conversion }]