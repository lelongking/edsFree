Enums = Apps.Merchant.Enums
simpleSchema.imports = new SimpleSchema
  importName : type: String, defaultValue: 'ĐƠN HÀNG'
  importType : type: Number, defaultValue: Enums.getValue('ImportTypes', 'initialize')
  dueDay     : type: Number, defaultValue: 90
  provider   : simpleSchema.OptionalString
  description: simpleSchema.OptionalString
  importCode : simpleSchema.OptionalString


  accounting          : type: String  , optional: true
  accountingConfirmAt : type: Date    , optional: true
  stocker             : type: String  , optional: true
  stockerConfirmAt    : type: Date    , optional: true
  transaction         : type: String  , optional: true
  successDate         : type: Date    , optional: true

  discountCash : type: Number, defaultValue: 0
  depositCash  : type: Number, defaultValue: 0
  totalPrice   : type: Number, defaultValue: 0
  finalPrice   : type: Number, defaultValue: 0

  merchant   : simpleSchema.DefaultMerchant
  allowDelete: simpleSchema.DefaultBoolean()
  creator    : simpleSchema.DefaultCreator
  version    : { type: simpleSchema.Version }


#------------ Import Detail ------------
  details                   : type: [Object], defaultValue: []
  'details.$._id'           : simpleSchema.UniqueId
  'details.$.product'       : type: String
  'details.$.productUnit'   : type: String

  'details.$.quality'               : {type: Number, min: 0}
  'details.$.price'         : {type: Number, min: 0}
  'details.$.discountCash'  : simpleSchema.DefaultNumber()

  'details.$.expire'        : {type: Date   , optional: true}
  'details.$.note'          : {type: String , optional: true}

#------------ Quantity Detail ------------
  'details.$.conversion'  : {type: Number, min: 1}
  'details.$.basicQuantity': {type: Number, min: 0}
  'details.$.basicQuantityReturn': {type: Number, min: 0}
  'details.$.basicOrderQuantity' : {type: Number, min: 0}
  'details.$.basicOrderQuantityReturn': {type: Number, min: 0} #(basicReturnQuantity - basicImportQuantity) if basicImportQuantity < basicReturnQuantity
  'details.$.basicQuantityAvailable'  : {type: Number, min: 0}


#------------ Method Import ------------
Schema.add 'imports', "Import", class Import
  @transform: (doc) ->
    doc.changeField = (field = undefined, value = undefined)->
      return console.log('Import da xac nhan') unless _.contains(typesCantEdit, doc.importType)
      if field isnt undefined and value isnt undefined
        optionUpdate = $set: {}

        if field is 'provider'
          if provider = Schema.providers.findOne(value)
            totalPrice = 0; discountCash = 0
            optionUpdate.$set.provider   = provider._id
            optionUpdate.$set.importName = Helpers.shortName2(provider.name)

            for instance, index in @details
              product = Schema.products.findOne(instance.product)
              productPrice  = product.getPrice(instance.productUnit, provider._id, 'import')
              totalPrice   += instance.quality * productPrice
              discountCash += instance.quality * instance.discountCash
              optionUpdate.$set["details.#{index}.price"] = productPrice

            optionUpdate.$set.totalPrice   = totalPrice
            optionUpdate.$set.discountCash = discountCash
            optionUpdate.$set.finalPrice   = totalPrice - discountCash

        else if field is 'dueDay'
          optionUpdate.$set.dueDay = Math.abs(value)
        else if field is 'discountCash'
          discountCash = if Math.abs(value) > @totalPrice then @totalPrice else Math.abs(value)
          optionUpdate.$set.discountCash = discountCash
          optionUpdate.$set.finalPrice   = @totalPrice - discountCash

        else if field is 'depositCash'
          optionUpdate.$set.depositCash = Math.abs(value)

        else if field is 'description'
          optionUpdate.$set.description = value

        Schema.imports.update(@_id, optionUpdate) if _.keys(optionUpdate.$set).length > 0

    doc.addImportDetail = (productUnitId, quality = 1, expireDay = undefined, note = undefined, callback) ->
      return console.log('Import da xac nhan') unless _.contains(typesCantEdit, doc.importType)

      product = Schema.products.findOne({'units._id': productUnitId})
      return console.log('Khong tim thay Product') if !product

      productUnit = _.findWhere(product.units, {_id: productUnitId})
      return console.log('Khong tim thay ProductUnit') if !productUnit

      price = product.getPrice(@provider, 'import')
      return console.log('Price not found..') if price is undefined

      return console.log("Price invalid (#{price})") if price < 0
      return console.log("Quantity invalid (#{quality})") if quality < 1

      detailFindQuery = {product: product._id, productUnit: productUnitId, price: price}
      detailFound = _.findWhere(@details, detailFindQuery)

      if detailFound
        detailIndex   = _.indexOf(@details, detailFound)
        updateQuery   = {$inc:{}}
        basicQuantity  = quality * productUnit.conversion

        updateQuery.$inc["details.#{detailIndex}.quality"]                = quality
        updateQuery.$inc["details.#{detailIndex}.basicQuantity"]          = basicQuantity
        updateQuery.$inc["details.#{detailIndex}.basicQuantityAvailable"] = basicQuantity
        recalculationImport(@_id) if Schema.imports.update(@_id, updateQuery, callback)

      else
        detailFindQuery.expire       = expireDay if expireDay
        detailFindQuery.note         = note if note

        detailFindQuery.quality      = quality
        detailFindQuery.conversion   = productUnit.conversion
        detailFindQuery.basicQuantity            = quality * productUnit.conversion
        detailFindQuery.basicQuantityAvailable   = quality * productUnit.conversion
        detailFindQuery.basicQuantityReturn      = 0
        detailFindQuery.basicOrderQuantity       = 0
        detailFindQuery.basicOrderQuantityReturn = 0

        if Schema.imports.update(@_id, { $push: {details: detailFindQuery} }, callback)
          recalculationImport(@_id); product.unitDenyDelete(productUnitId)


    doc.editImportDetail = (detailId, quality, expire, discountCash, price, callback) ->
      return console.log('Import da xac nhan') unless _.contains(typesCantEdit, doc.importType)

      for instance, i in @details
        if instance._id is detailId
          updateIndex = i
          updateInstance = instance
          break
      return console.log 'ImportDetailRow not found..' if !updateInstance

      predicate = $set:{}
      predicate.$set["details.#{updateIndex}.discountCash"] = discountCash  if discountCash isnt undefined
      predicate.$set["details.#{updateIndex}.price"] = price if price isnt undefined
      predicate.$set["details.#{updateIndex}.expire"] = expire if expire isnt undefined

      if quality isnt undefined
        basicQuantity = quality * updateInstance.conversion
        predicate.$set["details.#{updateIndex}.quality"]               = quality
        predicate.$set["details.#{updateIndex}.basicQuantity"]          = basicQuantity
        predicate.$set["details.#{updateIndex}.availableBasicQuantity"] = basicQuantity

      if _.keys(predicate.$set).length > 0
        recalculationImport(@_id) if Schema.imports.update(@_id, predicate, callback)

    doc.removeImportDetail = (detailId, callback) ->
      return console.log('Import da xac nhan') unless _.contains(typesCantEdit, doc.importType)
      return console.log('Import không tồn tại.') if (!self = Schema.imports.findOne doc._id)
      return console.log('ImportDetail không tồn tại.') if (!detailFound = _.findWhere(self.details, {_id: detailId}))

      detailIndex = _.indexOf(self.details, detailFound)
      removeDetailQuery = { $pull:{} }
      removeDetailQuery.$pull.details = self.details[detailIndex]
      recalculationImport(@_id) if Schema.imports.update(@_id, removeDetailQuery, callback)

    doc.importSubmit = ->
      return console.log('Import da xac nhan') unless _.contains(typesCantEdit, doc.importType)

      importQuery =
        _id        : doc._id
        creator    : Meteor.userId()
        merchant   : Merchant.getId()
        importType : Enums.getValue('ImportTypes', 'initialize')
      self = Schema.imports.findOne importQuery
      return console.log('Import không tồn tại.') if !self
      return console.log('Import rong.') if self.details.length is 0
      return console.log('Provider không tồn tại.') if !Schema.providers.findOne(self.provider)

      for detail, detailIndex in self.details
        product = Schema.products.findOne({'units._id': detail.productUnit})
        return console.log('Khong tim thay Product') if !product
        productUnit = _.findWhere(product.units, {_id: detail.productUnit})
        return console.log('Khong tim thay ProductUnit') if !productUnit

      if Schema.imports.update(self._id, $set:{importType : Enums.getValue('ImportTypes', 'staffConfirmed')})
        Meteor.call 'importAccountingConfirmed', self._id, (error, result) ->
          if result then console.log result
          Meteor.call 'importWarehouseConfirmed', self._id, (error, result) ->
            if result then console.log result


    doc.remove = -> Schema.imports.remove(@_id)

  @insert: (providerId, importName, description, callback) ->
    newImport = {}
    newImport.provider    = providerId if providerId
    newImport.description = description if description
    newImport.importName  = Helpers.shortName2(importName) if importName
    newImport.importType  = -1 if importName and !providerId
    importId = Schema.imports.insert(newImport, callback)
    if importId and providerId
      Meteor.users.update(Meteor.userId(), {$set: {'sessions.currentImport': importId}})
    return importId

  @findNotSubmitted: ->
    Schema.imports.find({
      creator    : Meteor.userId()
      merchant   : Merchant.getId()
      importType : Enums.getValue('ImportTypes', 'initialize')
    })

  @setSession: (importId) ->
    Meteor.users.update(Meteor.userId(), {$set: {'sessions.currentImport': importId}})


recalculationImport = (orderId) ->
  if importFound = Schema.imports.findOne(orderId)
    totalPrice = 0; discountCash = importFound.discountCash ? 0
    (totalPrice += detail.quality * detail.conversion * detail.price) for detail in importFound.details
    discountCash = totalPrice if importFound.discountCash > totalPrice
    Schema.imports.update importFound._id, $set:{
      totalPrice  : totalPrice
      discountCash: discountCash
      finalPrice  : totalPrice - discountCash
    }

typesCantEdit = [
  Enums.getValue('ImportTypes', 'inventory')
  Enums.getValue('ImportTypes', 'initialize')
]