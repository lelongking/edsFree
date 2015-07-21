checkProductInStockQuality = (orderDetails)->
  details = _.chain(orderDetails)
  .groupBy("product")
  .map (group, key) ->
    return {
    product      : group[0].product
    basicQuality : _.reduce( group, ((res, current) -> res + current.basicQuality), 0 )
    }
  .value()

  result = {valid: true, errorItem: []}
  if details.length > 0
    for currentDetail in details
      currentProduct = Document.Product.findOne(currentDetail.product)
      console.log currentProduct.qualities[0].availableQuality
      if currentProduct.qualities[0].availableQuality < currentDetail.basicQuality
        result.errorItem.push detail for detail in _.where(orderDetails, {product: currentDetail.product})
        (result.valid = false; result.message = "sản phẩm không đủ số lượng") if result.valid
  else
    result = {valid: false, message: "Danh sách sản phẩm trống." }

  return result

subtractQualityOnSales = (importDetails, saleDetail) ->
  transactionQuality = 0
  for importDetail in importDetails
    requiredQuality = saleDetail.basicQuality - transactionQuality
    takenQuality = if importDetail.availableQuality > requiredQuality then requiredQuality else importDetail.availableQuality

    updateProduct = {availableQuality: -takenQuality, inStockQuality: -takenQuality, saleQuality: takenQuality}

    transactionQuality += takenQuality
    if transactionQuality == saleDetail.basicQuality then break

  return transactionQuality == saleDetail.basicQuality

Enums = Apps.Merchant.Enums
Meteor.methods
  orderSellerConfirmed: (orderId)->
    user = Meteor.users.findOne(Meteor.userId())
    return {valid: false, error: 'user not found!'} if !user

    orderQuery =
      _id       : orderId
      creator   : user._id
      merchant  : user.profile.merchant
      orderType : Enums.getValue('OrderTypes', 'checked')
    orderFound = Schema.orders.findOne orderQuery
    return {valid: false, error: 'order not found!'} if !orderFound

    for detail, detailIndex in orderFound.details
      product = Schema.products.findOne({'units._id': detail.productUnit})
      return {valid: false, error: 'productUnit not found!'} if !product


    for detail in orderFound.details
      detailIndex = 0; updateQuery = {$inc:{}}

      product = Schema.products.findOne(detail.product)
      for unit, index in product.units
        if unit._id is detail.productUnit
          updateQuery.$inc["units.#{index}.quality.inOderQuality"]    = detail.basicQuality
          updateQuery.$inc["units.#{index}.quality.availableQuality"] = -detail.basicQuality
          break

      updateQuery.$inc["qualities.#{detailIndex}.inOderQuality"]    = detail.basicQuality
      updateQuery.$inc["qualities.#{detailIndex}.availableQuality"] = -detail.basicQuality
      Schema.products.update detail.product, updateQuery

    Schema.orders.update orderFound._id, $set: {orderType: Enums.getValue('OrderTypes', 'seller')}

  orderAccountingConfirmed: (orderId, transactionId)->
    user = Meteor.users.findOne(Meteor.userId())
    return {valid: false, error: 'user not found!'} if !user

    orderQuery =
      _id       : orderId
      merchant  : user.profile.merchant
      orderType : Enums.getValue('OrderTypes', 'seller')
    console.log orderQuery

    orderFound = Schema.orders.findOne orderQuery
    return {valid: false, error: 'order not found!'} if !orderFound

    customerFound = Schema.customers.findOne(orderFound.buyer)
    return {valid: false, error: 'customer not found!'} if !customerFound

    transactionInsert =
      transactionName : 'Phiếu Bán'
#      transactionCode :
#      description     :
      transactionType  : Enums.getValue('TransactionTypes', 'customer')
      receivable       : true
      owner            : customerFound._id
      parent           : orderFound._id
      beforeDebtBalance: customerFound.debtCash
      debtBalanceChange: orderFound.finalPrice
      paidBalanceChange: orderFound.depositCash
      latestDebtBalance: customerFound.debtCash + orderFound.finalPrice - orderFound.depositCash

    transactionInsert.dueDay = orderFound.dueDay if orderFound.dueDay

    if orderFound.depositCash >= orderFound.finalPrice # phiếu nhập đã thanh toán hết cho NCC
      transactionInsert.owedCash = 0
      transactionInsert.status   = Enums.getValue('TransactionStatuses', 'closed')
    else
      transactionInsert.owedCash = orderFound.finalPrice - orderFound.depositCash
      transactionInsert.status   = Enums.getValue('TransactionStatuses', 'tracking')

    if transactionId = Schema.transactions.insert(transactionInsert)
      customerUpdate =
        allowDelete : false
        paidCash    : customerFound.paidCash  + orderFound.depositCash
        debtCash    : customerFound.debtCash  + orderFound.finalPrice - orderFound.depositCash
        totalCash   : customerFound.totalCash + orderFound.finalPrice
      Schema.customers.update orderFound.buyer, $set: customerUpdate

    orderUpdate = $set:
      orderType          : Enums.getValue('OrderTypes', 'accounting')
      accounting         : user._id
      accountingConfirm  : true
      accountingConfirmAt: new Date()
      transaction        : transactionId
    Schema.orders.update orderFound._id, orderUpdate

  orderExportConfirmed: (orderId)->
    user = Meteor.users.findOne(Meteor.userId())
    return {valid: false, error: 'user not found!'} if !user

    orderQuery =
      _id       : orderId
      merchant  : user.profile.merchant
      orderType : Enums.getValue('OrderTypes', 'accounting')
    orderFound = Schema.orders.findOne orderQuery
    return {valid: false, error: 'order not found!'} if !orderFound

    for orderDetail in orderFound.details
      if product = Schema.products.findOne({'units._id': orderDetail.productUnit})
        detailIndex = 0; updateQuery = {$inc:{}}

        for unit, index in product.units
          if unit._id is orderDetail.productUnit
            updateQuery.$inc["units.#{index}.quality.saleQuality"]    = orderDetail.basicQuality
            updateQuery.$inc["units.#{index}.quality.inOderQuality"]  = -orderDetail.basicQuality
            updateQuery.$inc["units.#{index}.quality.inStockQuality"] = -orderDetail.basicQuality
            break

        updateQuery.$inc["qualities.#{detailIndex}.saleQuality"]    = orderDetail.basicQuality
        updateQuery.$inc["qualities.#{detailIndex}.inOderQuality"]  = -orderDetail.basicQuality
        updateQuery.$inc["qualities.#{detailIndex}.inStockQuality"] = -orderDetail.basicQuality
        Schema.products.update product._id, updateQuery


        if product.inventoryInitial
          basicImport = Schema.imports.find({
            importType              : $in:[Enums.getValue('ImportTypes', 'inventorySuccess'), Enums.getValue('ImportTypes', 'success')]
            'details.productUnit'   : orderDetail.productUnit
            'details.inStockQuality': {$gt: 0}
          }, {sort: {importType: 1} }).fetch()
          combinedImports = basicImport
          console.log combinedImports
          transactionQuality = 0
          for currentImport in combinedImports
            for importDetail, index in currentImport.details
              if importDetail.productUnit is orderDetail.productUnit
                requiredQuality = orderDetail.basicQuality - transactionQuality
                if importDetail.inStockQuality > requiredQuality
                  takenQuality = requiredQuality
                else
                  takenQuality = importDetail.inStockQuality

                order =
                  _id         : orderFound._id
                  buyer       : orderFound.buyer
                  productUnit : orderDetail.productUnit
                  quality     : takenQuality/orderDetail.conversion
                  salePrice   : orderDetail.price
                  basicQuality: takenQuality
                  createdAt   : new Date()

                updateImport = {$inc:{}, $push:{}}
                updateImport.$push["details.#{index}.orderId"]          = order
                updateImport.$inc["details.#{index}.saleQuality"]       = takenQuality
                updateImport.$inc["details.#{index}.inStockQuality"]    = -takenQuality
                updateImport.$inc["details.#{index}.availableQuality"]  = -takenQuality

                Schema.imports.update currentImport._id, updateImport

                transactionQuality += takenQuality
                break if transactionQuality == orderDetail.basicQuality
            break if transactionQuality == orderDetail.basicQuality


    orderUpdate = $set:
      orderType      : Enums.getValue('OrderTypes', 'export')
      export         : user._id
      exportConfirm  : true
      exportConfirmAt: new Date()
    Schema.orders.update orderFound._id, orderUpdate

  #TODO: chua bat dieu kiem
  orderImportConfirmed: (orderId)->
    user = Meteor.users.findOne(Meteor.userId())
    return {valid: false, error: 'user not found!'} if !user

    orderQuery =
      _id               : orderId
      merchant          : user.profile.merchant
      orderType         : Enums.getValue('OrderTypes', 'export')
      paymentsDelivery  : Enums.getValue('DeliveryTypes', 'delivery')
      'delivery.status' : Enums.getValue('DeliveryStatus', 'failDelivery')
    orderFound = Schema.orders.findOne orderQuery
    return {valid: false, error: 'order not found!'} if !orderFound

    orderUpdate = $set:
      orderType      : Enums.getValue('OrderTypes', 'import')
      import         : user._id
      importConfirm  : true
      importConfirmAt: new Date()
    Schema.orders.update orderFound._id, orderUpdate

  orderSuccessConfirmed: (orderId)->
    user = Meteor.users.findOne(Meteor.userId())
    return {valid: false, error: 'user not found!'} if !user

    orderQuery =
      _id       : orderId
      creator   : user._id
      merchant  : user.profile.merchant
      orderType : $in: [Enums.getValue('OrderTypes', 'export'),Enums.getValue('OrderTypes', 'import')]
    orderFound = Schema.orders.findOne orderQuery
    return {valid: false, error: 'order not found!'} if !orderFound

    if orderFound.paymentsDelivery is Enums.getValue('DeliveryTypes', 'delivery') and
      (orderFound.delivery.status is Enums.getValue('DeliveryStatus', 'unDelivered') or
        orderFound.delivery.status is Enums.getValue('DeliveryStatus', 'delivered'))
      return {valid: false, error: 'Delivery not finish!'}

    Schema.orders.update orderFound._id, $set: { orderType : Enums.getValue('OrderTypes', 'success') }
