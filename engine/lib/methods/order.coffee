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
      merchant  : user.profiles.merchant
      orderType : Enums.getValue('OrderTypes', 'checked')
    orderFound = Schema.orders.findOne orderQuery
    return {valid: false, error: 'order not found!'} if !orderFound

    for detail, detailIndex in orderFound.details
      product = Schema.products.findOne({'units._id': detail.productUnit})
      return {valid: false, error: 'productUnit not found!'} if !product


    for detail in orderFound.details
      detailIndex = 0; updateQuery = {$inc:{}}
      updateQuery.$inc["qualities.#{detailIndex}.inOderQuality"]    = detail.basicQuality
      updateQuery.$inc["qualities.#{detailIndex}.availableQuality"] = -detail.basicQuality
      Schema.products.update detail.product, updateQuery

    Schema.orders.update orderFound._id, $set: {orderType: Enums.getValue('OrderTypes', 'seller')}

  orderAccountingConfirmed: (orderId, transactionId)->
    user = Meteor.users.findOne(Meteor.userId())
    return {valid: false, error: 'user not found!'} if !user

    orderQuery =
      _id       : orderId
      merchant  : user.profiles.merchant
      orderType : Enums.getValue('OrderTypes', 'seller')
    console.log orderQuery
    orderFound = Schema.orders.findOne orderQuery
    return {valid: false, error: 'order not found!'} if !orderFound

    orderUpdate = $set:
      orderType          : Enums.getValue('OrderTypes', 'accounting')
      accounting         : user._id
      accountingConfirm  : true
      accountingConfirmAt: new Date()
    Schema.orders.update orderFound._id, orderUpdate

  orderExportConfirmed: (orderId)->
    user = Meteor.users.findOne(Meteor.userId())
    return {valid: false, error: 'user not found!'} if !user

    orderQuery =
      _id       : orderId
      merchant  : user.profiles.merchant
      orderType : Enums.getValue('OrderTypes', 'accounting')
    orderFound = Schema.orders.findOne orderQuery
    return {valid: false, error: 'order not found!'} if !orderFound

    for orderDetail in orderFound.details
      if product = Schema.products.findOne({'units._id': orderDetail.productUnit})
        detailIndex = 0; updateQuery = {$inc:{}}
        updateQuery.$inc["qualities.#{detailIndex}.saleQuality"]    = orderDetail.basicQuality
        updateQuery.$inc["qualities.#{detailIndex}.inOderQuality"]  = -orderDetail.basicQuality
        updateQuery.$inc["qualities.#{detailIndex}.inStockQuality"] = -orderDetail.basicQuality
        Schema.products.update product._id, updateQuery

        if product.inventoryInitial
          basicImport = Schema.imports.find({
            importType           : Enums.getValue('ImportTypes', 'inventorySuccess')
            'details.productUnit': orderDetail.productUnit
            inStockQuality       : {$gt: 0}
          }).fetch()
          combinedImports = basicImport

          transactionQuality = 0
          for currentImport in combinedImports
            for importDetail, index in currentImport.details
              if importDetail.productUnit is orderDetail.productUnit
                requiredQuality = orderDetail.basicQuality - transactionQuality
                if importDetail.inStockQuality > requiredQuality
                  takenQuality = requiredQuality
                else
                  takenQuality = importDetail.inStockQuality

                updateImport = $inc:{}, $push:{}
                updateImport.$inc["details.#{index}.saleQuality"]       = takenQuality
                updateImport.$inc["details.#{index}.inStockQuality"]    = -takenQuality
                updateImport.$inc["details.#{index}.availableQuality"]  = -takenQuality
                updateImport.$push["details.#{index}.orderId"]  = {_id: orderFound._id, quality: takenQuality}

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
      merchant          : user.profiles.merchant
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
      merchant  : user.profiles.merchant
      orderType : $in: [Enums.getValue('OrderTypes', 'export'),Enums.getValue('OrderTypes', 'import')]
    orderFound = Schema.orders.findOne orderQuery
    return {valid: false, error: 'order not found!'} if !orderFound

    if orderFound.paymentsDelivery is Enums.getValue('DeliveryTypes', 'delivery') and
      (orderFound.delivery.status is Enums.getValue('DeliveryStatus', 'unDelivered') or
        orderFound.delivery.status is Enums.getValue('DeliveryStatus', 'delivered'))
      return {valid: false, error: 'Delivery not finish!'}

    Schema.orders.update orderFound._id, $set: { orderType : Enums.getValue('OrderTypes', 'success') }
