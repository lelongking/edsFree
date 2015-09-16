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
  'details.$.basicQuantity' : {type: Number, min: 0}
  'details.$.conversion'    : {type: Number, min: 1}
  'details.$.price'         : {type: Number, min: 0}
  'details.$.discountCash'  : simpleSchema.DefaultNumber()

  'details.$.imports': type: [Object], optional: true #Import Detail
  'details.$.imports.$._id'         : type: String, optional: true
  'details.$.imports.$.detailId'    : type: String, optional: true
  'details.$.imports.$.product'     : type: String, optional: true
  'details.$.imports.$.productUnit' : type: String, optional: true
  'details.$.imports.$.provider'    : type: String, optional: true

  'details.$.imports.$.price'              : type: Number, min: 0
  'details.$.imports.$.conversion'         : type: Number, min: 1
  'details.$.imports.$.qualityReturn'      : type: Number, min: 0
  'details.$.imports.$.basicQuantityReturn': type: Number, min: 0
  'details.$.imports.$.note'               : type: String, optional: true
  'details.$.imports.$.createdAt'          : type: Date



  'details.$.orders': type: [Object], optional: true #Import Detail
  'details.$.orders.$._id'         : type: String, optional: true
  'details.$.orders.$.detailId'    : type: String, optional: true
  'details.$.orders.$.product'     : type: String, optional: true
  'details.$.orders.$.productUnit' : type: String, optional: true
  'details.$.orders.$.buyer'       : type: String, optional: true

  'details.$.orders.$.price'              : type: Number, min: 0
  'details.$.orders.$.conversion'         : type: Number, min: 1
  'details.$.orders.$.qualityReturn'      : type: Number, min: 0
  'details.$.orders.$.basicQuantityReturn': type: Number, min: 0
  'details.$.orders.$.note'               : type: String, optional: true
  'details.$.orders.$.createdAt'          : type: Date

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
        return console.log("Quantity invalid (#{quality})") if quality < 1

        detailFindQuery = {detailId: detailId, product: product._id, productUnit: productUnitId, price: price}
        detailFound = _.findWhere(@details, detailFindQuery)

        if detailFound
          detailIndex = _.indexOf(@details, detailFound)
          updateQuery = {$inc:{}}; basicQuantity = quality * productUnit.conversion
          updateQuery.$inc["details.#{detailIndex}.quality"]          = quality
          updateQuery.$inc["details.#{detailIndex}.basicQuantity"]     = basicQuantity
          recalculationReturn(@_id) if Schema.returns.update(@_id, updateQuery, callback)

        else
          detailFindQuery.quality       = quality
          detailFindQuery.conversion    = productUnit.conversion
          detailFindQuery.basicQuantity  = quality * productUnit.conversion
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
        basicQuantity = quality * updateInstance.conversion
        predicate.$set["details.#{updateIndex}.quality"] = quality
        predicate.$set["details.#{updateIndex}.basicQuantity"]     = basicQuantity

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
      return console.log('Order rỗng.') if orderFound.details.length is 0

      #so luong tra cua return
      productReturnQuantities = {}
      for returnDetail in currentReturn.details
        productReturnQuantities[returnDetail.product] = 0 unless productReturnQuantities[returnDetail.product]
        productReturnQuantities[returnDetail.product] += returnDetail.basicQuantity

      #so luong ton cua order
      productOrderQuantities = {}
      for orderDetail in orderFound.details
        productOrderQuantities[orderDetail.product] = 0 unless productOrderQuantities[orderDetail.product]
        productOrderQuantities[orderDetail.product] += orderDetail.basicQuantityAvailable

      #so sanh so luong
      for product, quantities of productReturnQuantities
        return console.log('So luong tra qua lon') if productOrderQuantities[product] < quantities

      #cap nhat vao product and import
      orderUpdateOption = $inc:{}; importUpdateOption = {}
      for product, quantities of productReturnQuantities
        takenReturnQuantity = 0
        for orderDetail, index in orderFound.details
          break if takenReturnQuantity is quantities

          #tim orderDetail
          if orderDetail.product is product
            availableReturnQuantity = quantities - takenReturnQuantity
            if orderDetail.basicQuantityAvailable < availableReturnQuantity
              returnQuantity       = orderDetail.basicQuantityAvailable
              takenReturnQuantity += orderDetail.basicQuantityAvailable
            else
              returnQuantity       = availableReturnQuantity
              takenReturnQuantity += availableReturnQuantity

            #cap nhat orderDetail
            orderUpdateOption.$inc["details.#{index}.basicQuantityReturn"]        = returnQuantity
            orderUpdateOption.$inc["details.#{index}.basicImportQuantityReturn"]  = returnQuantity
            orderUpdateOption.$inc["details.#{index}.basicQuantityAvailable"]     = -returnQuantity


            if orderDetail.basicImportQuantityDebit >= returnQuantity
              console.log 'this is import debit'
              orderUpdateOption.$inc["details.#{index}.basicImportQuantityDebit"] = -returnQuantity
            else
              orderUpdateOption.$inc["details.#{index}.basicImportQuantityDebit"] = -orderDetail.basicImportQuantityDebit
              console.log 'this is import not debit'
              console.log returnQuantity, orderDetail.basicImportQuantityDebit

              #cap nhat importDetail cua orderDetail
              returnImportQuantities = returnQuantity - orderDetail.basicImportQuantityDebit
              takenImportQuantity = 0
              for detail, indexDetail in orderDetail.imports
                break if takenImportQuantity is returnImportQuantities

                #tim importDetail
                if detail.product is product
                  availableImportReturnQuantity = returnImportQuantities - takenImportQuantity
                  if detail.basicQuantityAvailable < availableImportReturnQuantity
                    importReturnQuantity = detail.basicQuantityAvailable
                    takenImportQuantity += detail.basicQuantityAvailable
                  else
                    importReturnQuantity = availableImportReturnQuantity
                    takenImportQuantity += availableImportReturnQuantity

                  updateImportDetail = "details.#{index}.imports.#{indexDetail}"
                  orderUpdateOption.$inc["#{updateImportDetail}.basicQuantityReturn"]    = importReturnQuantity
                  orderUpdateOption.$inc["#{updateImportDetail}.basicQuantityAvailable"] = -importReturnQuantity

                  #cap nhat Import
                  for importDetail, indexImportDetail in Schema.imports.findOne(detail._id).details
                    if importDetail._id is detail.detailId
                      importUpdateOption[detail._id] = {$inc:{}} unless importUpdateOption[detail._id]

                      if importUpdateOption[detail._id].$inc["details.#{indexImportDetail}.basicQuantityAvailable"] is undefined
                        importUpdateOption[detail._id].$inc["details.#{indexImportDetail}.basicQuantityAvailable"] = 0
                      importUpdateOption[detail._id].$inc["details.#{indexImportDetail}.basicQuantityAvailable"] -= takenImportQuantity

                      if importUpdateOption[detail._id].$inc["details.#{indexImportDetail}.basicOrderQuantityReturn"] is undefined
                        importUpdateOption[detail._id].$inc["details.#{indexImportDetail}.basicOrderQuantityReturn"] = 0
                      importUpdateOption[detail._id].$inc["details.#{indexImportDetail}.basicOrderQuantityReturn"] += takenImportQuantity

                      if importDetail.basicOrderQuantity < (importDetail.basicOrderQuantityReturn + takenImportQuantity)
                        console.log('Import Detail Error, ko du so luong'); return


      if transactionId = createTransactionByCustomer(currentReturn)
        for productId, quantities of productReturnQuantities
          productUpdate =
            $inc:
              'quantities.0.inStockQuantity'    : quantities
              'quantities.0.returnSaleQuantity' : quantities
              'quantities.0.availableQuantity'  : quantities
          Schema.products.update productId, productUpdate

        for importId, importUpdate of importUpdateOption
          Schema.imports.update importId, importUpdate

        orderUpdateOption.$set = {allowDelete: false}
        Schema.orders.update @parent, orderUpdateOption

        Schema.returns.update @_id, $set:{
          returnStatus: Enums.getValue('ReturnStatus', 'success')
          transaction : transactionId
          staffConfirm: Meteor.userId()
          successDate : new Date()
        }

    doc.deleteCustomerReturn = ->

    doc.submitProviderReturn = ->
      currentReturn = Schema.returns.findOne(@_id)
      return console.log('Ban khong co quyen.') unless User.hasManagerRoles()
      return console.log('Return đã hoàn thành.') if @returnStatus is Enums.getValue('ReturnStatus', 'success')
      return console.log('Return không đúng.') unless @returnType is Enums.getValue('ReturnTypes', 'provider')
      return console.log('Return rỗng.') if @details.length is 0
      return console.log('Phieu Order Khong Chinh Xac.') if (importFound = Schema.imports.findOne(@parent)) is undefined

      productUpdateList = []; importUpdateOption = $inc:{}
      for returnDetail in currentReturn.details
        currentProductQuantity = 0; findProductUnit = false
        productUpdateList.push(updateProductQuery(returnDetail, currentReturn.returnType))

        for importDetail, index in importFound.details
          if importDetail.productUnit is returnDetail.productUnit
            findProductUnit = true; currentProductQuantity += importDetail.basicQuantityAvailable

            importUpdateOption.$inc["details.#{index}.basicQuantityReturn"]    = returnDetail.basicQuantity
            importUpdateOption.$inc["details.#{index}.basicQuantityAvailable"] = -returnDetail.basicQuantity

        return console.log('ReturnDetail Khong Chinh Xac.') unless findProductUnit
        return console.log('So luong tra qua lon') if (currentProductQuantity - returnDetail.basicQuantity) < 0

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
        productUpdate.$inc["units.#{index}.quality.inStockQuantity"]      = -returnDetail.basicQuantity
        productUpdate.$inc["units.#{index}.quality.availableQuantity"]    = -returnDetail.basicQuantity
        productUpdate.$inc["units.#{index}.quality.returnImportQuantity"] = returnDetail.basicQuantity
        break

    productUpdate.$inc["quantities.#{detailIndex}.inStockQuantity"]      = -returnDetail.basicQuantity
    productUpdate.$inc["quantities.#{detailIndex}.availableQuantity"]    = -returnDetail.basicQuantity
    productUpdate.$inc["quantities.#{detailIndex}.returnImportQuantity"] = returnDetail.basicQuantity

  else if returnType is Enums.getValue('ReturnTypes', 'customer')
    for unit, index in product.units
      if unit._id is returnDetail.productUnit
        productUpdate.$inc["units.#{index}.quality.inStockQuantity"]    = returnDetail.basicQuantity
        productUpdate.$inc["units.#{index}.quality.returnSaleQuantity"] = returnDetail.basicQuantity
        productUpdate.$inc["units.#{index}.quality.availableQuantity"]  = returnDetail.basicQuantity
        break

    productUpdate.$inc["quantities.#{detailIndex}.inStockQuantity"]    = returnDetail.basicQuantity
    productUpdate.$inc["quantities.#{detailIndex}.returnSaleQuantity"] = returnDetail.basicQuantity
    productUpdate.$inc["quantities.#{detailIndex}.availableQuantity"]  = returnDetail.basicQuantity

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
      isRoot           : true
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
      isRoot           : true
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