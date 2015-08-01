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

createTransaction = (customer, order)->
  transactionInsert =
    transactionName : 'Phiếu Bán'
#      transactionCode :
#    description      : 'Phiếu Bán'
    transactionType  : Enums.getValue('TransactionTypes', 'customer')
    receivable       : true
    owner            : customer._id
    parent           : order._id
    beforeDebtBalance: customer.debtCash + customer.loanCash
    debtBalanceChange: order.finalPrice
    paidBalanceChange: order.depositCash
    latestDebtBalance: customer.debtCash + customer.loanCash +  order.finalPrice - order.depositCash

  transactionInsert.dueDay = order.dueDay if order.dueDay

  if order.depositCash >= order.finalPrice # phiếu nhập đã thanh toán hết cho NCC
    transactionInsert.owedCash = 0
    transactionInsert.status   = Enums.getValue('TransactionStatuses', 'closed')
  else
    transactionInsert.owedCash = order.finalPrice - order.depositCash
    transactionInsert.status   = Enums.getValue('TransactionStatuses', 'tracking')

  if transactionId = Schema.transactions.insert(transactionInsert)
    customerUpdate =
      allowDelete : false
      paidCash    : customer.paidCash  + order.depositCash
      debtCash    : customer.debtCash  + order.finalPrice - order.depositCash
      totalCash   : customer.totalCash + order.finalPrice
    Schema.customers.update order.buyer, $set: customerUpdate
    Schema.customerGroups.update order.group, $inc:{totalCash: (order.finalPrice - order.depositCash)} if customer.group

  return transactionId

updateSubtractQualityInProductUnit = (product, orderDetail) ->
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

findAllImport = (productUnitId) ->
  basicImport = Schema.imports.find({
    importType              : $in:[Enums.getValue('ImportTypes', 'inventorySuccess'), Enums.getValue('ImportTypes', 'success')]
    'details.productUnit'   : productUnitId
    'details.inStockQuality': {$gt: 0}
  }, {sort: {importType: 1} }).fetch()
  combinedImports = basicImport; console.log combinedImports
  combinedImports

updateSubtractQualityInImport = (orderFound, orderDetail, combinedImports) ->
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

Enums = Apps.Merchant.Enums
Meteor.methods
  customerToOrder: (customerId)->
    try
      user = Meteor.users.findOne(Meteor.userId())
      throw {valid: false, error: 'user not found!'} if !user

      customer = Schema.customers.findOne({_id: customerId, merchant: user.profile.merchant})
      throw {valid: false, error: 'customer not found!'} if !customer

      orderFound = Schema.orders.findOne({
        seller      : user._id
        buyer       : customer._id
        merchant    : user.profile.merchant
        orderType   : Enums.getValue('OrderTypes', 'initialize')
        orderStatus : Enums.getValue('OrderStatus', 'initialize')
      }, {sort: {'version.createdAt': -1}})

      if orderFound
        Order.setSession(orderFound._id)
      else
        Order.setSession(orderId) if orderId = Order.insert(customer._id, user._id, customer.name)

    catch error
      throw new Meteor.Error('customerToOrder', error)


  orderSellerConfirm: (orderId)->
    user = Meteor.users.findOne(Meteor.userId())
    return {valid: false, error: 'user not found!'} if !user

    orderQuery =
      _id         : orderId
      seller      : user._id
      merchant    : user.profile.merchant
      orderType   : Enums.getValue('OrderTypes', 'initialize')
      orderStatus : Enums.getValue('OrderStatus', 'initialize')
    console.log orderQuery
    orderFound = Schema.orders.findOne orderQuery

    return {valid: false, error: 'order not found!'} if !orderFound

    for detail, detailIndex in orderFound.details
      product = Schema.products.findOne({'units._id': detail.productUnit})
      return {valid: false, error: 'productUnit not found!'} if !product

    orderUpdate = $set:
      orderType      : Enums.getValue('OrderTypes', 'tracking')
      orderStatus    : Enums.getValue('OrderStatus', 'sellerConfirm')
      sellerConfirmAt: new Date()
    Schema.orders.update orderFound._id, orderUpdate

  orderAccountConfirm: (orderId)->
    user = Meteor.users.findOne(Meteor.userId())
    return {valid: false, error: 'user not found!'} if !user

    orderQuery =
      _id         : orderId
      merchant    : user.profile.merchant
      orderType   : Enums.getValue('OrderTypes', 'tracking')
      orderStatus : Enums.getValue('OrderStatus', 'sellerConfirm')
    orderFound = Schema.orders.findOne orderQuery
    return {valid: false, error: 'order not found!'} if !orderFound

    for detail in orderFound.details
      if product = Schema.products.findOne(detail.product)
        for unit in product.units
          if unit._id is detail.productUnit
            crossAvailable = (unit.quality.availableQuality - detail.basicQuality)/unit.conversion
            if product.inventoryInitial and crossAvailable < 0
              return {valid: false, error: 'san pham khong du!'}
      else
        return {valid: false, error: 'khong tim thay product!'}

    orderUpdate = $set:
      orderStatus        : Enums.getValue('OrderStatus', 'accountingConfirm')
      accounting         : Meteor.userId()
      accountingConfirmAt: new Date()
    Schema.orders.update orderFound._id, orderUpdate
    Schema.customers.update orderFound.buyer, $addToSet:{orderWaiting: orderFound._id}

    updateUserId = if orderFound.staff then orderFound.staff else orderFound.seller
    Meteor.users.update(updateUserId, $inc:{'profile.turnoverCash': orderFound.finalPrice})

  orderExportConfirm: (orderId)->
    user = Meteor.users.findOne(Meteor.userId())
    return {valid: false, error: 'user not found!'} if !user

    orderQuery =
      _id         : orderId
      merchant    : user.profile.merchant
      orderType   : Enums.getValue('OrderTypes', 'tracking')
      orderStatus : Enums.getValue('OrderStatus', 'accountingConfirm')
    orderFound = Schema.orders.findOne orderQuery
    return {valid: false, error: 'order not found!'} if !orderFound

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

    orderUpdate = $set:
      orderStatus    : Enums.getValue('OrderStatus', 'exportConfirm')
      export         : Meteor.userId()
      exportConfirmAt: new Date()
    Schema.orders.update orderFound._id, orderUpdate

  orderSuccessConfirm: (orderId, success = true)->
    user = Meteor.users.findOne(Meteor.userId())
    return {valid: false, error: 'user not found!'} if !user

    orderQuery =
      _id         : orderId
      merchant    : user.profile.merchant
      orderType   : Enums.getValue('OrderTypes', 'tracking')
      orderStatus : Enums.getValue('OrderStatus', 'exportConfirm')
    orderFound = Schema.orders.findOne orderQuery
    return {valid: false, error: 'order not found!'} if !orderFound

    if success
      orderUpdate = $set:
        orderType   : Enums.getValue('OrderTypes', 'success')
        orderStatus : Enums.getValue('OrderStatus', 'success')
      Schema.orders.update orderFound._id, orderUpdate
    else
      orderUpdate = $set:
        orderType   : Enums.getValue('OrderTypes', 'fail')
        orderStatus : Enums.getValue('OrderStatus', 'fail')
      Schema.orders.update orderFound._id, orderUpdate

  orderUndoConfirm: (orderId)->
    user = Meteor.users.findOne(Meteor.userId())
    return {valid: false, error: 'user not found!'} if !user

    orderQuery =
      _id         : orderId
      merchant    : user.profile.merchant
      orderType   : {$in:[
        Enums.getValue('OrderTypes', 'success')
        Enums.getValue('OrderTypes', 'fail')
      ]}
      orderStatus : {$in:[
        Enums.getValue('OrderStatus', 'success')
        Enums.getValue('OrderStatus', 'fail')
      ]}
    orderFound = Schema.orders.findOne orderQuery
    return {valid: false, error: 'order not found!'} if !orderFound

    orderUpdate = $set:
      orderType   : Enums.getValue('OrderTypes', 'tracking')
      orderStatus : Enums.getValue('OrderStatus', 'exportConfirm')
    Schema.orders.update orderFound._id, orderUpdate

  orderImportConfirm: (orderId)->
    user = Meteor.users.findOne(Meteor.userId())
    return {valid: false, error: 'user not found!'} if !user

    orderQuery =
      _id         : orderId
      merchant    : user.profile.merchant
      orderType   : Enums.getValue('OrderTypes', 'fail')
      orderStatus : Enums.getValue('OrderStatus', 'fail')
    orderFound = Schema.orders.findOne orderQuery
    return {valid: false, error: 'order not found!'} if !orderFound

    for detail in orderFound.details
      detailIndex = 0; updateQuery = {$inc:{}}

      product = Schema.products.findOne(detail.product)
      for unit, index in product.units
        if unit._id is detail.productUnit
          updateQuery.$inc["units.#{index}.quality.inOderQuality"]    = -detail.basicQuality
          updateQuery.$inc["units.#{index}.quality.availableQuality"] = detail.basicQuality
          break

      updateQuery.$inc["qualities.#{detailIndex}.inOderQuality"]    = -detail.basicQuality
      updateQuery.$inc["qualities.#{detailIndex}.availableQuality"] = detail.basicQuality
      Schema.products.update detail.product, updateQuery

    orderUpdate = $set:
      orderStatus     : Enums.getValue('OrderStatus', 'importConfirm')
      import          : Meteor.userId()
      importConfirmAt : new Date()
    Schema.orders.update orderFound._id, orderUpdate

  orderFinishConfirm: (orderId)->
    user = Meteor.users.findOne(Meteor.userId())
    return {valid: false, error: 'user not found!'} if !user

    orderQuery =
      _id         : orderId
      merchant    : user.profile.merchant
      orderType   : {$in:[Enums.getValue('OrderTypes', 'success'), Enums.getValue('OrderTypes', 'fail')]}
      orderStatus : {$in:[Enums.getValue('OrderStatus', 'success'), Enums.getValue('OrderStatus', 'importConfirm')]}
    orderFound = Schema.orders.findOne orderQuery
    return {valid: false, error: 'order not found!'} if !orderFound

    customerFound = Schema.customers.findOne(orderFound.buyer)
    return {valid: false, error: 'customer not found!'} if !customerFound

    merchantFound = Schema.merchants.findOne(user.profile.merchant)
    return {valid: false, error: 'merchant not found!'} if !merchantFound

    if orderFound.orderType is Enums.getValue('OrderTypes', 'success')
      customerFound = Schema.customers.findOne(orderFound.buyer)
      return {valid: false, error: 'customer not found!'} if !customerFound

      transactionId = createTransaction(customerFound, orderFound)
      return {valid: false, error: 'customer not found!'} if !transactionId

      for orderDetail in orderFound.details
        if product = Schema.products.findOne({'units._id': orderDetail.productUnit})
          updateSubtractQualityInProductUnit(product, orderDetail)

          if product.inventoryInitial
            combinedImports = findAllImport(orderDetail.productUnit)
            updateSubtractQualityInImport(orderFound, orderDetail, combinedImports)

      orderUpdate = $set:
        orderStatus : Enums.getValue('OrderStatus', 'finish')
        transaction : transactionId
        successDate : new Date()
        orderCode   :"#{Helpers.orderCodeCreate(customerFound.billNo)}/#{Helpers.orderCodeCreate(merchantFound.saleBill)}"

      Schema.orders.update orderFound._id, orderUpdate
      Schema.customers.update customerFound._id, {$inc: {billNo: 1},$addToSet:{orderSuccess: orderFound._id}, $pull: {orderWaiting: orderFound._id}}
      Schema.merchants.update(merchantFound._id, $inc:{saleBill: 1})

    else
      orderUpdate = $set:
        orderStatus : Enums.getValue('OrderStatus', 'finish')
      Schema.orders.update orderFound._id, orderUpdate
      Schema.customers.update orderFound.buyer, {$addToSet:{orderFailure: orderFound._id}, $pull: {orderWaiting: orderFound._id}}



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
