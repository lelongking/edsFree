Enums = Apps.Merchant.Enums
simpleSchema.returns = new SimpleSchema
  returnMethods    : simpleSchema.DefaultNumber()

  owner  : simpleSchema.OptionalString
  parent : simpleSchema.OptionalString

  returnName  : type: String, defaultValue: 'Trả hàng'
  description : simpleSchema.OptionalString
  returnCode  : simpleSchema.OptionalString

  returnType  : type: Number,  defaultValue: Enums.getValue('ReturnTypes', 'customer')
  returnStatus: type: Number,  defaultValue: Enums.getValue('ReturnStatus', 'initialize')

  discountCash : type: Number, defaultValue: 0
  depositCash  : type: Number, defaultValue: 0
  totalPrice   : type: Number, defaultValue: 0
  finalPrice   : type: Number, defaultValue: 0

  transaction : type: String, optional: true
  staffConfirm: type: String, optional: true
  successDate : type: Date  , optional: true

  merchant    : simpleSchema.DefaultMerchant
  allowDelete : simpleSchema.DefaultBoolean()
  creator     : simpleSchema.DefaultCreator
  version: { type: simpleSchema.Version }

  details                   : type: [Object], defaultValue: []
  'details.$._id'           : simpleSchema.UniqueId
  'details.$.detailId'      : type: String
  'details.$.product'       : type: String
  'details.$.productUnit'   : type: String
  'details.$.quality'       : {type: Number, min: 0}
  'details.$.basicQuality'  : {type: Number, min: 0}
  'details.$.conversion'    : {type: Number, min: 1}
  'details.$.price'         : {type: Number, min: 0}
  'details.$.discountCash'  : simpleSchema.DefaultNumber()

  'details.$.imports': type: [Object], optional: true #Import Detail
  'details.$.imports.$._id'         : type: String, optional: true
  'details.$.imports.$.detailId'    : type: String, optional: true
  'details.$.imports.$.product'     : type: String, optional: true
  'details.$.imports.$.productUnit' : type: String, optional: true
  'details.$.imports.$.provider'    : type: String, optional: true

  'details.$.imports.$.conversion'        : type: Number, min: 1
  'details.$.imports.$.qualityReturn'     : type: Number, min: 0
  'details.$.imports.$.basicQualityReturn': type: Number, min: 0

  'details.$.imports.$.price'       : type: Number
  'details.$.imports.$.note'        : type: String, optional: true
  'details.$.imports.$.createdAt'   : type: Date

Schema.add 'returns', "Return", class Return
  @transform: (doc) ->
    doc.remove = ->
      Schema.returns.remove @_id if @allowDelete and User.hasManagerRoles()

    doc.changeDescription = (description)->
      option = $set:{description: description}
      Schema.returns.update @_id, option

    doc.selectOwner = (ownerId)->
      if @returnType is Enums.getValue('ReturnTypes', 'customer')
        if customer = Schema.customers.findOne ownerId
          changeOwnerUpdate = $unset:{parent: true}, $set:{
            owner       : customer._id
            returnName  : Helpers.shortName2(customer.name)
            discountCash: 0
            depositCash : 0
            totalPrice  : 0
            finalPrice  : 0
            details     : []
          }
      else if @returnType is Enums.getValue('ReturnTypes', 'provider')
        if provider = Schema.providers.findOne ownerId
          changeOwnerUpdate = $unset:{parent: true}, $set:{
            owner       : provider._id
            returnName  : Helpers.shortName2(provider.name)
            discountCash: 0
            depositCash : 0
            totalPrice  : 0
            finalPrice  : 0
            details     : []
          }

      Schema.returns.update(@_id, changeOwnerUpdate) if changeOwnerUpdate

    doc.selectParent = (parentId)->
      if @returnType is Enums.getValue('ReturnTypes', 'customer')
        parent = Schema.orders.findOne({_id: parentId, merchant: Merchant.getId(), buyer: @owner})
      else if @returnType is Enums.getValue('ReturnTypes', 'provider')
        parent = Schema.imports.findOne({_id: parentId, merchant: Merchant.getId(), provider: @owner})

      if parent
        Schema.returns.update @_id, $set:{
          parent      : parent._id
          returnCode  : parent.orderCode ? parent.importCode
          discountCash: 0
          depositCash : 0
          totalPrice  : 0
          finalPrice  : 0
          details     : []
        }

    doc.addReturnDetail = (detailId, productUnitId, quality = 1, price, callback)->
      if @parent
        product = Schema.products.findOne({'units._id': productUnitId})
        return console.log('Khong tim thay Product') if !product

        productUnit = _.findWhere(product.units, {_id: productUnitId})
        return console.log('Khong tim thay ProductUnit') if !productUnit

        price = product.getPrice(productUnitId, @provider, 'import') unless price
        return console.log('Price not found..') if price is undefined

        return console.log("Price invalid (#{price})") if price < 0
        return console.log("Quality invalid (#{quality})") if quality < 1

        detailFindQuery = {detailId: detailId, product: product._id, productUnit: productUnitId, price: price}
        detailFound = _.findWhere(@details, detailFindQuery)

        if detailFound
          detailIndex = _.indexOf(@details, detailFound)
          updateQuery = {$inc:{}}; basicQuality = quality * productUnit.conversion
          updateQuery.$inc["details.#{detailIndex}.quality"]          = quality
          updateQuery.$inc["details.#{detailIndex}.basicQuality"]     = basicQuality
          recalculationReturn(@_id) if Schema.returns.update(@_id, updateQuery, callback)

        else
          detailFindQuery.quality       = quality
          detailFindQuery.conversion    = productUnit.conversion
          detailFindQuery.basicQuality  = quality * productUnit.conversion
          recalculationReturn(@_id) if Schema.returns.update(@_id, { $push: {details: detailFindQuery} }, callback)

    doc.editReturnDetail = (detailId, quality, discountCash, price, callback) ->
      for instance, i in @details
        if instance._id is detailId
          updateIndex = i
          updateInstance = instance
          break
      return console.log 'ReturnDetailRow not found..' if !updateInstance

      predicate = $set:{}
      predicate.$set["details.#{updateIndex}.discountCash"] = discountCash  if discountCash isnt undefined
      predicate.$set["details.#{updateIndex}.price"] = price if price isnt undefined

      if quality isnt undefined
        basicQuality = quality * updateInstance.conversion
        predicate.$set["details.#{updateIndex}.quality"] = quality
        predicate.$set["details.#{updateIndex}.basicQuality"]     = basicQuality

      if _.keys(predicate.$set).length > 0
        recalculationReturn(@_id) if Schema.returns.update(@_id, predicate, callback)

    doc.removeReturnDetail = (detailId, callback) ->
      return console.log('Return không tồn tại.') if (!self = Schema.returns.findOne doc._id)
      return console.log('ReturnDetail không tồn tại.') if (!detailFound = _.findWhere(self.details, {_id: detailId}))
      detailIndex = _.indexOf(self.details, detailFound)
      removeDetailQuery = { $pull:{} }
      removeDetailQuery.$pull.details = self.details[detailIndex]
      recalculationReturn(@_id) if Schema.returns.update(@_id, removeDetailQuery, callback)

    doc.submitCustomerReturn = ->
      currentReturn = Schema.returns.findOne(@_id)
      return console.log('Ban khong co quyen.') unless User.hasManagerRoles()
      return console.log('Return đã hoàn thành.') if @returnStatus is Enums.getValue('ReturnStatus', 'success')
      return console.log('Return không đúng.') unless @returnType is Enums.getValue('ReturnTypes', 'customer')
      return console.log('Return rỗng.') if @details.length is 0
      return console.log('Phieu Order Khong Chinh Xac.') if (orderFound = Schema.orders.findOne(@parent)) is undefined

      productUpdateList = []; orderUpdateOption = $inc:{}, $set:{}
      for returnDetail in currentReturn.details
        currentProductQuality = 0; findProductUnit = false
        productUpdateList.push(updateProductQuery(returnDetail, currentReturn.returnType))

        for orderDetail, index in orderFound.details
          console.log orderDetail
          if orderDetail.productUnit is returnDetail.productUnit
            findProductUnit = true; currentProductQuality += orderDetail.basicQualityAvailable

            orderUpdateOption.$inc["details.#{index}.basicQualityReturn"]    = returnDetail.basicQuality
            orderUpdateOption.$inc["details.#{index}.basicQualityAvailable"] = -returnDetail.basicQuality

            basicImportQualityReturn = orderDetail.basicImportQuality - (orderDetail.basicQuality - returnDetail.basicQuality)
            if basicImportQualityReturn < 0
              orderUpdateOption.$set["details.#{index}.basicImportQualityDebit"]  = basicImportQualityReturn
              orderUpdateOption.$set["details.#{index}.basicImportQualityReturn"] = 0
            else
              orderUpdateOption.$set["details.#{index}.basicImportQualityDebit"]   = 0
              orderUpdateOption.$set["details.#{index}.basicImportQualityReturn"]  = Math.abs(basicImportQualityReturn)

              returnQuality = 0
              for detail, indexDetail in orderDetail.imports
                orderUpdateOption.$inc["details.#{index}.imports.#{indexDetail}.basicQualityReturn"]    = basicImportQualityReturn
                orderUpdateOption.$inc["details.#{index}.imports.#{indexDetail}.basicQualityAvailable"] = -basicImportQualityReturn

                requiredQuality = basicImportQualityReturn - returnQuality
                availableQuality = detail.basicQualityAvailable - requiredQuality

                if availableQuality > 0
                  takenQuality = requiredQuality
                else
                  takenQuality = detail.basicQualityAvailable

                for importDetail, indexImportDetail in Schema.imports.findOne(detail._id).details
                  if importDetail._id is detail.detailId
                    updateImport = $inc:{}
                    updateImport.$inc["details.#{indexImportDetail}.basicQualityAvailable"]   = takenQuality
                    updateImport.$inc["details.#{indexImportDetail}.basicOrderQualityReturn"] = takenQuality
                    Schema.imports.update detail._id, updateImport

        return console.log('ReturnDetail Khong Chinh Xac.') unless findProductUnit
        return console.log('So luong tra qua lon') if (currentProductQuality - returnDetail.basicQuality) < 0

      if transactionId = createTransactionByCustomer(currentReturn)
        Schema.products.update(product._id, product.updateOption) for product in productUpdateList
        Schema.orders.update @parent, orderUpdateOption
        Schema.returns.update @_id, $set:{
          returnStatus: Enums.getValue('ReturnStatus', 'success')
          transaction : transactionId
          staffConfirm: Meteor.userId()
          successDate : new Date()
        }


    doc.submitProviderReturn = ->
      currentReturn = Schema.returns.findOne(@_id)
      return console.log('Ban khong co quyen.') unless User.hasManagerRoles()
      return console.log('Return đã hoàn thành.') if @returnStatus is Enums.getValue('ReturnStatus', 'success')
      return console.log('Return không đúng.') unless @returnType is Enums.getValue('ReturnTypes', 'provider')
      return console.log('Return rỗng.') if @details.length is 0
      return console.log('Phieu Order Khong Chinh Xac.') if (importFound = Schema.imports.findOne(@parent)) is undefined

      productUpdateList = []; importUpdateOption = $inc:{}
      for returnDetail in currentReturn.details
        currentProductQuality = 0; findProductUnit = false
        productUpdateList.push(updateProductQuery(returnDetail, currentReturn.returnType))

        for importDetail, index in importFound.details
          if importDetail.productUnit is returnDetail.productUnit
            findProductUnit = true; currentProductQuality += importDetail.basicQualityAvailable

            importUpdateOption.$inc["details.#{index}.basicQualityReturn"]    = returnDetail.basicQuality
            importUpdateOption.$inc["details.#{index}.basicQualityAvailable"] = -returnDetail.basicQuality

        return console.log('ReturnDetail Khong Chinh Xac.') unless findProductUnit
        return console.log('So luong tra qua lon') if (currentProductQuality - returnDetail.basicQuality) < 0

      if transactionId = createTransactionByProvider(currentReturn)
        Schema.products.update(product._id, product.updateOption) for product in productUpdateList
        Schema.imports.update @parent, importUpdateOption
        Schema.returns.update @_id, $set:{
          returnStatus: Enums.getValue('ReturnStatus', 'success')
          transaction : transactionId
          staffConfirm: Meteor.userId()
          successDate : new Date()
        }


  @insert: (returnType = Enums.getValue('ReturnTypes', 'customer'), ownerId = undefined, parentId = undefined)->
    insertOption = {}
    if Enums.getValue('ReturnTypes', 'customer') is returnType or Enums.getValue('ReturnTypes', 'provider') is returnType
      insertOption.returnType = returnType
    else return

    if ownerId
      ownerIsCustomer = Schema.customers.findOne(ownerId)
      ownerIsProvider = Schema.providers.findOne(ownerId) unless ownerIsCustomer

      if ownerIsCustomer
        parent = Schema.orders.findOne({
          _id         : parentId
          buyer       : ownerId
          orderType   : Enums.getValue('OrderTypes', 'success')
          orderStatus : Enums.getValue('OrderStatus', 'finish')
        })
      else if ownerIsProvider
        parent = Schema.imports.findOne({
          _id        : parentId
          provider   : ownerId
          importType : Enums.getValue('ImportTypes', 'success')
        })

      insertOption.parent = parentId if parent

      if ownerIsCustomer or ownerIsProvider
        insertOption.owner = ownerId
        if ownerIsCustomer
          insertOption.returnType = Enums.getValue('OrderTypes', 'customer')
          insertOption.returnName = Helpers.shortName2(ownerIsCustomer.name)
        else
          insertOption.returnType = Enums.getValue('OrderTypes', 'provider')
          insertOption.returnName = Helpers.shortName2(ownerIsProvider.name)

    Schema.returns.insert insertOption

  @findNotSubmitOf: (returnType = 'customer')->
    if returnType is 'customer' or returnType is 'provider'
      Schema.returns.find({
        creator     : Meteor.userId()
        merchant    : Merchant.getId()
        returnType  : Enums.getValue('ReturnTypes', returnType)
        returnStatus: Enums.getValue('ReturnStatus', 'initialize')
      })

  @setReturnSession: (returnId, returnType = 'customer')->
    if returnType is 'customer'
      updateSession = $set: {'sessions.currentCustomerReturn': returnId}
    else if returnType is 'provider'
      updateSession = $set: {'sessions.currentProviderReturn': returnId}

    Meteor.users.update(Meteor.userId(), updateSession) if updateSession

recalculationReturn = (returnId) ->
  if returnFound = Schema.returns.findOne(returnId)
    totalPrice = 0; discountCash = returnFound.discountCash
    (totalPrice += detail.quality * detail.price) for detail in returnFound.details
    discountCash = totalPrice if returnFound.discountCash > totalPrice
    Schema.returns.update returnFound._id, $set:{
      totalPrice  : totalPrice
      discountCash: discountCash
      finalPrice  : totalPrice - discountCash
    }

updateProductQuery = (returnDetail, returnType)->
  detailIndex = 0; productUpdate = {$inc:{}}
  product = Schema.products.findOne({'units._id': returnDetail.productUnit})

  if returnType is Enums.getValue('ReturnTypes', 'provider')
    for unit, index in product.units
      if unit._id is returnDetail.productUnit
        productUpdate.$inc["units.#{index}.quality.inStockQuality"]      = -returnDetail.basicQuality
        productUpdate.$inc["units.#{index}.quality.availableQuality"]    = -returnDetail.basicQuality
        productUpdate.$inc["units.#{index}.quality.returnImportQuality"] = returnDetail.basicQuality
        break

    productUpdate.$inc["quantities.#{detailIndex}.inStockQuality"]      = -returnDetail.basicQuality
    productUpdate.$inc["quantities.#{detailIndex}.availableQuality"]    = -returnDetail.basicQuality
    productUpdate.$inc["quantities.#{detailIndex}.returnImportQuality"] = returnDetail.basicQuality

  else if returnType is Enums.getValue('ReturnTypes', 'customer')
    for unit, index in product.units
      if unit._id is returnDetail.productUnit
        productUpdate.$inc["units.#{index}.quality.inStockQuality"]    = returnDetail.basicQuality
        productUpdate.$inc["units.#{index}.quality.returnSaleQuality"] = returnDetail.basicQuality
        productUpdate.$inc["units.#{index}.quality.availableQuality"]  = returnDetail.basicQuality
        break

    productUpdate.$inc["quantities.#{detailIndex}.inStockQuality"]    = returnDetail.basicQuality
    productUpdate.$inc["quantities.#{detailIndex}.returnSaleQuality"] = returnDetail.basicQuality
    productUpdate.$inc["quantities.#{detailIndex}.availableQuality"]  = returnDetail.basicQuality

  return {_id: returnDetail.product, updateOption: productUpdate}

createTransactionByCustomer = (currentReturn)->
  if customer = Schema.customers.findOne(currentReturn.owner)
    transactionInsert =
      transactionName : 'Phiếu Trả Hàng'
  #      transactionCode :
  #    description      : 'Phiếu Bán'
      transactionType  : Enums.getValue('TransactionTypes', 'return')
      receivable       : false #khach hang da tra
      owner            : customer._id
      parent           : currentReturn._id
      beforeDebtBalance: customer.totalCash
      debtBalanceChange: currentReturn.depositCash
      paidBalanceChange: currentReturn.finalPrice
      latestDebtBalance: customer.totalCash - currentReturn.finalPrice - currentReturn.depositCash

    transactionInsert.dueDay    = currentReturn.dueDay if currentReturn.dueDay
    transactionInsert.owedCash  = currentReturn.finalPrice + currentReturn.depositCash
    transactionInsert.status    = Enums.getValue('TransactionStatuses', 'tracking')

    if transactionId = Schema.transactions.insert(transactionInsert)
      Schema.customers.update customer._id, $inc: {returnCash: currentReturn.finalPrice, totalCash : -currentReturn.finalPrice}
      Schema.customerGroups.update customer.group, $inc:{totalCash: -currentReturn.finalPrice} if customer.group
    return transactionId

createTransactionByProvider = (currentReturn)->
  if provider = Schema.providers.findOne(currentReturn.owner)
    transactionInsert =
      transactionName : 'Phiếu Trả Hàng'
  #      transactionCode :
  #    description      : 'Phiếu Bán'
      transactionType  : Enums.getValue('TransactionTypes', 'return')
      receivable       : false #nha cung cap da tra
      owner            : provider._id
      parent           : currentReturn._id
      beforeDebtBalance: provider.totalCash
      debtBalanceChange: currentReturn.depositCash
      paidBalanceChange: currentReturn.finalPrice
      latestDebtBalance: provider.totalCash - currentReturn.finalPrice - currentReturn.depositCash

    transactionInsert.dueDay    = currentReturn.dueDay if currentReturn.dueDay
    transactionInsert.owedCash  = currentReturn.finalPrice + currentReturn.depositCash
    transactionInsert.status    = Enums.getValue('TransactionStatuses', 'tracking')

    if transactionId = Schema.transactions.insert(transactionInsert)
      Schema.providers.update provider._id, $inc: {
        returnCash: currentReturn.finalPrice
        totalCash : -currentReturn.finalPrice
      }
    return transactionId