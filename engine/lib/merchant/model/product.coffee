Enums = Apps.Merchant.Enums
simpleSchema.products = new SimpleSchema
  name            : {type: String   ,unique  : true, index: 1}
  nameSearch      : simpleSchema.searchSource('name')
  description     : {type: String ,optional: true}
  image           : {type: String ,optional: true}
  group           : {type: String ,optional: true}
  inventoryInitial: simpleSchema.DefaultBoolean(false)
  lastExpire      : {type: Date   ,optional: true}


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
  'units.$.isBase'     : type: Boolean, defaultValue: false
  'units.$.allowDelete': type: Boolean, defaultValue: true
  'units.$.lastExpire' : type: Date   , optional: true
  'units.$.createdAt'  : simpleSchema.DefaultCreatedAt

  'units.$.priceBooks'                      : type: [Object], optional: true
  'units.$.priceBooks.$.priceBook'          : type: String

  'units.$.priceBooks.$.basicSale'          : type: Number, optional: true
  'units.$.priceBooks.$.salePrice'          : type: Number, optional: true
  'units.$.priceBooks.$.discountSalePrice'  : type: Number, optional: true
  'units.$.priceBooks.$.updateSalePriceAt'  : type: Date  , optional: true

  'units.$.priceBooks.$.basicImport'        : type: Number, optional: true
  'units.$.priceBooks.$.importPrice'        : type: Number, optional: true
  'units.$.priceBooks.$.discountImportPrice': type: Number, optional: true
  'units.$.priceBooks.$.updateImportPriceAt': type: Date  , optional: true

  'units.$.quality'                     : type: Object
  'units.$.quality.upperGapQuality'     : type: Number
  'units.$.quality.inStockQuality'      : type: Number
  'units.$.quality.inOderQuality'       : type: Number
  'units.$.quality.availableQuality'    : type: Number
  'units.$.quality.saleQuality'         : type: Number
  'units.$.quality.returnSaleQuality'   : type: Number
  'units.$.quality.importQuality'       : type: Number
  'units.$.quality.returnImportQuality' : type: Number

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
      console.log priceBook.importPrice, priceBook.priceBook, priceBookId
      return priceBook.importPrice if priceBook.priceBook is priceBookId
    return undefined

Schema.add 'products', "Product", class Product
  @transform: (doc) ->
    doc.unitName = -> doc.units[0].name if doc.units.length > 0
    doc.basicUnit= -> doc.units[0]._id if doc.units.length > 0
    doc.allQuality = -> doc.qualities[0].inStockQuality if doc.qualities.length > 0
    doc.changeName = (name)->

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
          _id         : productUnitId
          name        : name
          conversion  : conversion
          priceBooks  : priceBook
          isBase      : false
          allowDelete : true
          quality     :
            availableQuality    : 0
            importQuality       : 0
            inOderQuality       : 0
            inStockQuality      : 0
            returnImportQuality : 0
            returnSaleQuality   : 0
            saleQuality         : 0
            upperGapQuality     : 0

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

      if updateInstance
        unitUpdateQuery = $set:{}
        if option.name and unitNameIsNotExist
          unitUpdateQuery.$set["units.#{updateUnitIndex}.name"] = option.name

        if option.barcode and barcodeIsNotExit
          unitUpdateQuery.$set["units.#{updateUnitIndex}.barcode"] = option.barcode

        if option.conversion
          if updateInstance.allowDelete and updateInstance.isBase is false and option.conversion and option.conversion >= 1
            unitUpdateQuery.$set["units.#{updateUnitIndex}.conversion"] = option.conversion

            for priceBook, priceBookIndex in updateInstance.priceBooks
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
          PriceBook.reUpdateByRemoveProductUnit(productUnit._id) for productUnit in @units

          Schema.productGroups.update @group, $pull: {products: @_id }


    doc.productConfirm = ->
      if @status is Enums.getValue('ProductStatuses', 'initialize')
        Schema.products.update @_id, $set:{status: Enums.getValue('ProductStatuses', 'confirmed')}

    doc.submitInventory = (inventoryDetails)->
      if User.roleIsManager()
        isValid = false
        (isValid = true if detail.quality > 0) for detail in inventoryDetails

        if isValid
          importId = Import.insert(null,'Tồn kho đầu kỳ', null)
          if importFound = Schema.imports.findOne(importId)
            for detail in inventoryDetails
              importFound.addImportDetail(detail._id, detail.quality, detail.expriceDay) if detail.quality > 0

            Meteor.call 'importInventory', importFound._id, (error, result) -> console.log error, result
  #        #TODO: chua tinh tru kho khi ban hang truoc

        Schema.products.update @_id, $set:{
          inventoryInitial: true
          allowDelete     : false
          status          : Enums.getValue('ProductStatuses', 'confirmed')
        }



  @insert: (option = {})->
    priceBookBasic = Schema.priceBooks.findOne({priceBookType: 0, merchant: Merchant.getId()})
    priceBook = [{
      priceBook: priceBookBasic._id
      basicSale           : 0
      salePrice           : 0
      discountSalePrice   : 0
      updateSalePriceAt   : new Date()
      basicImport         : 0
      importPrice         : 0
      discountImportPrice : 0
      updateImportPriceAt : new Date()
    }]

    quality =
      availableQuality    : 0
      importQuality       : 0
      inOderQuality       : 0
      inStockQuality      : 0
      returnImportQuality : 0
      returnSaleQuality   : 0
      saleQuality         : 0
      upperGapQuality     : 0



    productUnitId = Random.id()
    option.units = [{
      _id         : productUnitId
      name        : 'Chai'
      allowDelete : false
      isBase      : true
      conversion  : 1
      priceBooks  : priceBook
      quality     : quality
    }]

    console.log option
    if newProductId = Schema.products.insert option
      PriceBook.addProductUnit(productUnitId)
      Product.setSession(newProductId)
      ProductGroup.addProduct(newProductId)
    newProductId

  @nameIsExisted: (name, merchant = null) ->
    existedQuery = {name: name, merchant: merchant ? Meteor.user().profile.merchant}
    Schema.priceBooks.findOne(existedQuery)

  @setSession: (currentProductId) ->
    Meteor.subscribe('productManagementCurrentProductData', currentProductId) if Meteor.isClient
    Meteor.users.update(Meteor.userId(), {$set: {'sessions.currentProduct': currentProductId}})
