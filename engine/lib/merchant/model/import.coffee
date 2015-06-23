simpleSchema.imports = new SimpleSchema
  importName : simpleSchema.DefaultString('ĐƠN HÀNG')
  provider   : simpleSchema.OptionalString
  importCode : simpleSchema.OptionalString
  importType : simpleSchema.DefaultNumber()

  merchant   : simpleSchema.DefaultMerchant
  allowDelete: simpleSchema.DefaultBoolean()
  creator    : simpleSchema.DefaultCreator
  version    : { type: simpleSchema.Version }

  profiles                : type: Object , optional: true
  'profiles.description'  : simpleSchema.OptionalString
  'profiles.discountCash' : simpleSchema.DefaultNumber()
  'profiles.depositCash'  : simpleSchema.DefaultNumber()
  'profiles.totalPrice'   : simpleSchema.DefaultNumber()
  'profiles.finalPrice'   : simpleSchema.DefaultNumber()

  details                   : type: [Object], defaultValue: []
  'details.$._id'           : simpleSchema.UniqueId
  'details.$.product'       : type: String
  'details.$.productUnit'   : type: String
  'details.$.quality'       : {type: Number, min: 0}
  'details.$.price'         : {type: Number, min: 0}
  'details.$.discountCash'  : simpleSchema.DefaultNumber()
  'details.$.expire'        : {type: Date, optional: true}
  'details.$.conversion'    : {type: Number, min: 1}
  'details.$.basicQuality'  : {type: Number, min: 0}

  'details.$.importQuality'       : {type: Number, min: 0}
  'details.$.saleQuality'         : simpleSchema.DefaultNumber()
  'details.$.returnSaleQuality'   : simpleSchema.DefaultNumber()
  'details.$.returnImportQuality' : simpleSchema.DefaultNumber()
  'details.$.inStockQuality'      : simpleSchema.DefaultNumber()
  'details.$.inOderQuality'       : simpleSchema.DefaultNumber()
  'details.$.availableQuality'    : simpleSchema.DefaultNumber()

Schema.add 'imports', "Import", class Import
  @transform: (doc) ->
    doc.test = ->
      console.log doc
      console.log @

    doc.changeProvider= (providerId, callback)->
      provider = Schema.providers.findOne(providerId)
      if provider
        totalPrice = 0; discountCash = 0
        predicate = $set:{ provider: provider._id, importName: Helpers.shortName2(provider.name) }

        for instance, index in @details
          product = Schema.products.findOne(instance.product)
          productPrice  = product.getPrice(instance.productUnit, provider._id, 'import')
          totalPrice   += instance.quality * productPrice
          discountCash += instance.quality * instance.discountCash
          predicate.$set["details.#{index}.price"] = productPrice

        predicate.$set["profiles.totalPrice"]   = totalPrice
        predicate.$set["profiles.discountCash"] = discountCash
        predicate.$set["profiles.finalPrice"]   = totalPrice - discountCash
        Schema.imports.update @_id, predicate, callback

    doc.changeDepositCash = (depositCash, callback) ->
      option = $set:{'profiles.depositCash': Math.abs(depositCash)}
      Schema.imports.update @_id, option, callback

    doc.changeDiscountCash = (discountCash, callback) ->
      console.log discountCash
      discountCash = if Math.abs(discountCash) > @profiles.totalPrice then @profiles.totalPrice else Math.abs(discountCash)
      option = $set:{'profiles.discountCash': discountCash}
      Schema.imports.update @_id, option, callback

    doc.addImportDetail = (productUnitId, quality = 1, callback) ->
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
        updateQuery.$inc["details.#{detailIndex}.importQuality"]    = basicQuality
        updateQuery.$inc["details.#{detailIndex}.inStockQuality"]   = basicQuality
        updateQuery.$inc["details.#{detailIndex}.availableQuality"] = basicQuality
        recalculationImport(@_id) if Schema.imports.update(@_id, updateQuery, callback)

      else
        detailFindQuery.quality       = quality
        detailFindQuery.conversion    = productUnit.conversion
        detailFindQuery.basicQuality  = quality * productUnit.conversion
        detailFindQuery.importQuality = detailFindQuery.basicQuality
        recalculationImport(@_id) if Schema.imports.update(@_id, { $push: {details: detailFindQuery} }, callback)

    doc.editImportDetail = (detailId, quality, expire, discountCash, price, callback) ->
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
        basicQuality = quality * updateInstance.conversion
        predicate.$set["details.#{updateIndex}.quality"] = quality
        predicate.$set["details.#{updateIndex}.basicQuality"]     = basicQuality
        predicate.$set["details.#{updateIndex}.importQuality"]    = basicQuality
        predicate.$set["details.#{updateIndex}.inStockQuality"]   = basicQuality
        predicate.$set["details.#{updateIndex}.availableQuality"] = basicQuality

      if _.keys(predicate.$set).length > 0
        recalculationImport(@_id) if Schema.imports.update(@_id, predicate, callback)

    doc.removeImportDetail = (detailId, callback) ->
      return console.log('Import không tồn tại.') if (!self = Schema.imports.findOne doc._id)
      return console.log('ImportDetail không tồn tại.') if (!detailFound = _.findWhere(self.details, {_id: detailId}))
      detailIndex = _.indexOf(self.details, detailFound)
      removeDetailQuery = { $pull:{} }
      removeDetailQuery.$pull.details = self.details[detailIndex]
      recalculationImport(@_id) if Schema.imports.update(@_id, removeDetailQuery, callback)

    doc.changeDescription = (description, callback)->
      option = $set:{'profiles.description': description}
      Schema.imports.update @_id, option, callback

    doc.importSubmit = ->
      self = Schema.imports.findOne({_id: doc._id})
      return console.log('Import không tồn tại.') if !self
      #      return console.log('Import đã Submit') if self.orderType isnt Enum.orderType.created

      for detail, detailIndex in self.details
        product = Schema.products.findOne({'units._id': detail.productUnit})
        return console.log('Khong tim thay Product') if !product
        productUnit = _.findWhere(product.units, {_id: detail.productUnit})
        return console.log('Khong tim thay ProductUnit') if !productUnit

      Meteor.call 'importSubmitted', self._id, (error, result) -> if error then console.log error


    doc.remove = (callback)-> Schema.imports.remove(@_id, callback)

  @insert: (providerId, description, callback) ->
    newImport = {}
    newImport.provider = providerId if providerId
    newImport['profiles.description'] = description if description
    Schema.imports.insert newImport, callback

  @findNotSubmitted: ->
    Schema.imports.find({importType: 0})

  @setSession: (importId) ->
    Meteor.users.update(Meteor.userId(), {$set: {'sessions.currentImport': importId}})


recalculationImport = (orderId) ->
  if orderFound = Schema.imports.findOne(orderId)
    totalPrice = 0; discountCash = orderFound.profiles.discountCash
    (totalPrice += detail.quality * detail.price) for detail in orderFound.details
    discountCash = totalPrice if orderFound.profiles.discountCash > totalPrice
    Schema.imports.update orderFound._id, $set:{
      'profiles.totalPrice'  : totalPrice
      'profiles.discountCash': discountCash
      'profiles.finalPrice'  : totalPrice - discountCash
    }