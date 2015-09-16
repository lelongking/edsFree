checkProductInStockQuantity = (orderDetails)->
  details = _.chain(orderDetails)
  .groupBy("product")
  .map (group, key) ->
    return {
    product      : group[0].product
    basicQuantity : _.reduce( group, ((res, current) -> res + current.basicQuantity), 0 )
    }
  .value()

  result = {valid: true, errorItem: []}
  if details.length > 0
    for currentDetail in details
      currentProduct = Document.Product.findOne(currentDetail.product)
      console.log currentProduct.quantities[0].availableQuantity
      if currentProduct.quantities[0].availableQuantity < currentDetail.basicQuantity
        result.errorItem.push detail for detail in _.where(orderDetails, {product: currentDetail.product})
        (result.valid = false; result.message = "sản phẩm không đủ số lượng") if result.valid
  else
    result = {valid: false, message: "Danh sách sản phẩm trống." }

  return result

subtractQuantityOnSales = (importDetails, saleDetail) ->
  transactionQuantity = 0
  for importDetail in importDetails
    requiredQuantity = saleDetail.basicQuantity - transactionQuantity
    takenQuantity = if importDetail.availableQuantity > requiredQuantity then requiredQuantity else importDetail.availableQuantity

    updateProduct = {availableQuantity: -takenQuantity, inStockQuantity: -takenQuantity, saleQuantity: takenQuantity}

    transactionQuantity += takenQuantity
    if transactionQuantity == saleDetail.basicQuantity then break

  return transactionQuantity == saleDetail.basicQuantity

createTransaction = (customer, order)->
  transactionInsert =
    transactionName : 'Phiếu Bán'
#      transactionCode :
#    description      : 'Phiếu Bán'
    transactionType  : Enums.getValue('TransactionTypes', 'customer')
    receivable       : true
    isRoot           : true
    owner            : customer._id
    parent           : order._id
    isUseCode        : order.depositCash > 0
    beforeDebtBalance: customer.totalCash
    debtBalanceChange: order.finalPrice
    paidBalanceChange: order.depositCash
    latestDebtBalance: customer.totalCash + order.finalPrice - order.depositCash


  transactionInsert.dueDay    = order.dueDay if order.dueDay
  transactionInsert.owedCash  = Math.abs(order.finalPrice - order.depositCash)

  if order.depositCash >= order.finalPrice # phiếu nhập đã thanh toán hết cho NCC
    transactionInsert.status = Enums.getValue('TransactionStatuses', 'closed')
  else
    transactionInsert.status = Enums.getValue('TransactionStatuses', 'tracking')

  if transactionInsert.isUseCode
    console.log 'insertCode'

  if transactionId = Schema.transactions.insert(transactionInsert)
    customerUpdate =
      paidCash    : order.depositCash
      debtCash    : order.finalPrice
      totalCash   : order.finalPrice - order.depositCash

    Schema.customers.update order.buyer, { $inc: customerUpdate, $set: {allowDelete : false} }
    Schema.customerGroups.update order.group, $inc:{totalCash: customerUpdate.totalCash} if customer.group

  return transactionId

updateSubtractQuantityInProductUnit = (product, orderDetail) ->
  detailIndex = 0; updateProductQuery = {$inc:{}}
  updateProductQuery.$inc["quantities.#{detailIndex}.saleQuantity"]    = orderDetail.basicQuantity
  updateProductQuery.$inc["quantities.#{detailIndex}.inOderQuantity"]  = -orderDetail.basicQuantity
  updateProductQuery.$inc["quantities.#{detailIndex}.inStockQuantity"] = -orderDetail.basicQuantity

  if Schema.products.update(product._id, updateProductQuery)
    if product.inventoryInitial
      inStockQuantity = product.quantities[0].inStockQuantity - orderDetail.basicQuantity
      normsQuantity   = product.quantities[0].normsQuantity
      optionQuantity =
        notificationType: 'notify'
        product         : product._id
        group           : Enums.getObject('NotificationGroups')['productQuantity'].value
      productQuantityFound = Schema.notifications.findOne(optionQuantity)
      if inStockQuantity > 0
        if normsQuantity > inStockQuantity
          optionQuantity.message = "Sản phẩm #{product.name} sắp hết hàng. (còn #{inStockQuantity}/#{normsQuantity} #{product.units[0].name})"
          if productQuantityFound
            Schema.notifications.update productQuantityFound._id, $set:{message: optionQuantity.message}
          else
            Schema.notifications.insert optionQuantity

        else
          Schema.notifications.remove(productQuantityFound._id) if productQuantityFound

      else
        optionQuantity.message = "Sản phẩm #{product.name} đã hết hàng."
        if productQuantityFound
          Schema.notifications.update productQuantityFound._id, $set:{message: optionQuantity.message}
        else
          Schema.notifications.insert optionQuantity




findAllImport = (productId) ->
  basicImport = Schema.imports.find({
    importType                      : $in:[Enums.getValue('ImportTypes', 'inventorySuccess'), Enums.getValue('ImportTypes', 'success')]
    'details.product'               : productId
    'details.basicQuantityAvailable': {$gt: 0}
  }, {sort: {importType: 1} }).fetch()
  combinedImports = basicImport; console.log combinedImports
  combinedImports

updateSubtractQuantityInImport = (orderFound, orderDetail, detailIndex, combinedImports) ->
  transactionQuantity = 0
  for currentImport in combinedImports #danh sach phieu Import
    for importDetail, index in currentImport.details #danh sach ImportDetail
      if importDetail.product is orderDetail.product #so sanh ProductUnit
        requiredQuantity = orderDetail.basicQuantity - transactionQuantity

        availableQuantity = importDetail.basicQuantityAvailable - requiredQuantity
        if availableQuantity > 0
          takenQuantity = requiredQuantity
#          orderDetailNote = "còn #{availableQuantity}, phiếu #{currentImport.importCode}"
        else
          takenQuantity = importDetail.basicQuantityAvailable
#          orderDetailNote = "hết hàng, phiếu #{currentImport.importCode}"

        updateImport = $inc:{}
        updateImport.$inc["details.#{index}.basicOrderQuantity"]     = takenQuantity
        updateImport.$inc["details.#{index}.basicQuantityAvailable"] = -takenQuantity
        Schema.imports.update currentImport._id, updateImport

        updateOrderQuery = {$push:{}, $inc:{}}
        importDetailOfOrder =
          _id         : currentImport._id
          detailId    : importDetail._id
          product     : importDetail.product
          productUnit : importDetail.productUnit
          provider    : currentImport.provider
          price       : importDetail.price
          conversion  : importDetail.conversion
          quality     : takenQuantity/importDetail.conversion
#          note        : orderDetailNote
          createdAt   : new Date()
          basicQuantity          : takenQuantity
          basicQuantityReturn    : 0
          basicQuantityAvailable : takenQuantity

        updateOrderQuery.$push["details.#{detailIndex}.imports"]                = importDetailOfOrder
        updateOrderQuery.$inc["details.#{detailIndex}.basicImportQuantity"]      = takenQuantity
        updateOrderQuery.$inc["details.#{detailIndex}.basicImportQuantityDebit"] = -takenQuantity

        if transactionQuantity is orderDetail.basicQuantity
          updateOrderQuery.$set = {}
          updateOrderQuery.$set["details.#{detailIndex}.importIsValid"] = true
        Schema.orders.update(orderFound._id, updateOrderQuery)

        transactionQuantity += takenQuantity
        break if transactionQuantity is orderDetail.basicQuantity
    break if transactionQuantity is orderDetail.basicQuantity

Enums = Apps.Merchant.Enums
Meteor.methods
  customerToOrder: (customerId)->
    try
      user = Meteor.users.findOne(Meteor.userId())
      throw {valid: false, error: 'user not found!'} unless user

      customer = Schema.customers.findOne({_id: customerId, merchant: user.profile.merchant})
      throw {valid: false, error: 'customer not found!'} unless customer

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

  deleteOrder: (orderId)->
    user = Meteor.users.findOne(Meteor.userId())
    return {valid: false, error: 'user not found!'} unless user
    return {valid: false, error: 'user not permission!'} unless User.hasManagerRoles()

    query =
      seller      : user._id
      buyer       : $exists: true
      merchant    : user.profile.merchant
      orderType   : Enums.getValue('OrderTypes', 'success')
      orderStatus : Enums.getValue('OrderStatus', 'finish')

    currentOrderQuery = _.clone(query)
    currentOrderQuery._id = orderId

    currentOrderFound = Schema.orders.findOne currentOrderQuery
    return {valid: false, error: 'order not found!'} unless currentOrderFound
    return {valid: false, error: 'order not delete!'} unless currentOrderFound.allowDelete

    customerFound = Schema.customers.findOne(currentOrderFound.buyer)
    return {valid: false, error: 'customer not found!'} unless customerFound

    merchantFound = Schema.merchants.findOne(user.profile.merchant)
    return {valid: false, error: 'merchant not found!'} unless merchantFound

#    lastOrderQuery = _.clone(query)
#    lastOrderQuery.successDate = {$gt:currentOrderFound.successDate}
#    lastOrderFound = Schema.orders.findOne lastOrderQuery
#
#    console.log currentOrderFound._id, lastOrderFound?._id

    productLists = []
    for item in currentOrderFound.details
      product = Schema.products.findOne(item.product)
      return {valid: false, error: 'product not found!'} unless product
      productLists.push(product)


    for orderDetail in currentOrderFound.details
      product = _.findWhere(productLists, {_id: orderDetail.product})

      updateProductQuery =
        $inc:
          'quantities.0.saleQuantity'     : -orderDetail.basicQuantity
          'quantities.0.availableQuantity': orderDetail.basicQuantity
          'quantities.0.inStockQuantity'  : orderDetail.basicQuantity
      console.log updateProductQuery
      Schema.products.update product._id, updateProductQuery

      if product.inventoryInitial
        #da nhap ton dau ky
        for orderImportDetail in orderDetail.imports

          #tim Import
          if currentImport = Schema.imports.findOne(orderImportDetail._id)

            #tim ImportDetail
            for importDetail, index in currentImport.details

              #so sanh ImportDetail giong voi orderImportDetail
              if importDetail._id is orderImportDetail.detailId

               #cap nhat lai Imports
                updateImport = $inc:{}
                updateImport.$inc["details.#{index}.basicOrderQuantity"]     = -orderImportDetail.basicQuantity
                updateImport.$inc["details.#{index}.basicQuantityAvailable"] = orderImportDetail.basicQuantity
                console.log updateImport
                Schema.imports.update currentImport._id, updateImport

    if Schema.orders.remove(currentOrderFound._id)
      Meteor.call 'deleteTransaction', currentOrderFound.transaction

#    if lastOrderFound
#    else








Meteor.methods
  orderSellerConfirm: (orderId)->
    user = Meteor.users.findOne(Meteor.userId())
    return {valid: false, error: 'user not found!'} unless user

    orderQuery =
      _id         : orderId
      seller      : user._id
      merchant    : user.profile.merchant
      orderType   : Enums.getValue('OrderTypes', 'initialize')
      orderStatus : Enums.getValue('OrderStatus', 'initialize')
    orderFound = Schema.orders.findOne orderQuery

    return {valid: false, error: 'order not found!'} unless orderFound

    buyer = Schema.customers.findOne(orderFound.buyer)
    return {valid: false, error: 'buyer not found!'} unless buyer

    merchant = Schema.merchants.findOne(user.profile.merchant)
    return {valid: false, error: 'merchant not found!'} unless merchant

    for detail, detailIndex in orderFound.details
      product = Schema.products.findOne({'units._id': detail.productUnit})
      return {valid: false, error: 'productUnit not found!'} unless product

    customerBillNo = Helpers.orderCodeCreate(buyer.saleBillNo ? '00')
    merchantBillNo = Helpers.orderCodeCreate(merchant.saleBillNo ? '00')

    orderUpdate = $set:
      orderType      : Enums.getValue('OrderTypes', 'tracking')
      orderStatus    : Enums.getValue('OrderStatus', 'sellerConfirm')
      sellerConfirmAt: new Date()
      orderCode      : customerBillNo + '/' + merchantBillNo
    console.log orderUpdate

    if Schema.orders.update(orderFound._id, orderUpdate)
      Schema.customers.update(buyer._id, $inc: {saleBillNo: 1})
      Schema.merchants.update(merchant._id, $inc: {saleBillNo: 1})

      optionNewOrder =
        notificationType: 'notify'
        group           : Enums.getObject('NotificationGroups')['newOrder'].value
        message         : "Nhân viên #{user.profile.name} tạo phiếu bán cho khách hàng #{buyer.name}"
        reads           : [Meteor.userId()]
      Schema.notifications.insert(optionNewOrder)


  orderAccountConfirm: (orderId)->
    user = Meteor.users.findOne(Meteor.userId())
    return {valid: false, error: 'user not found!'} unless user

    orderQuery =
      _id         : orderId
      merchant    : user.profile.merchant
      orderType   : Enums.getValue('OrderTypes', 'tracking')
      orderStatus : Enums.getValue('OrderStatus', 'sellerConfirm')
    orderFound = Schema.orders.findOne orderQuery
    return {valid: false, error: 'order not found!'} unless orderFound

    for productId, details of _.groupBy(orderFound.details, (item) -> item.product)
      if product = Schema.products.findOne(productId)
        availableQuantity = product.quantities[0].availableQuantity ? 0

        for orderDetail in details
          saleQuantity  = 0 unless saleQuantity
          saleQuantity += orderDetail.basicQuantity

        if product.inventoryInitial and (availableQuantity - saleQuantity) < 0
          return {valid: false, error: 'san pham khong du!'}

      else
        return {valid: false, error: 'khong tim thay product!'}

    orderUpdate = $set:
      orderStatus        : Enums.getValue('OrderStatus', 'accountingConfirm')
      accounting         : Meteor.userId()
      accountingConfirmAt: new Date()
    Schema.orders.update orderFound._id, orderUpdate
    if Schema.customers.update(orderFound.buyer, $addToSet:{orderWaiting: orderFound._id})
      buyer = Schema.customers.findOne(orderFound.buyer)
      optionNewOrder =
        notificationType: 'notify'
        sender          : Meteor.userId()
        receiver        : orderFound.seller
        group           : Enums.getObject('NotificationGroups')['newOrder'].value
        message         : "Nhân viên #{user.profile.name} đã ghi nhận phiếu của khách hàng #{buyer.name}"
        reads           : [Meteor.userId()]
      Schema.notifications.insert(optionNewOrder)

#    updateUserId = if orderFound.staff then orderFound.staff else orderFound.seller
#    Meteor.users.update(updateUserId, $inc:{'profile.turnoverCash': orderFound.finalPrice})


  orderExportConfirm: (orderId)->
    user = Meteor.users.findOne(Meteor.userId())
    return {valid: false, error: 'user not found!'} unless user

    orderQuery =
      _id         : orderId
      merchant    : user.profile.merchant
      orderType   : Enums.getValue('OrderTypes', 'tracking')
      orderStatus : Enums.getValue('OrderStatus', 'accountingConfirm')
    orderFound = Schema.orders.findOne orderQuery
    return {valid: false, error: 'order not found!'} unless orderFound

    for detail in orderFound.details
      if product = Schema.products.findOne(detail.product)
        updateQuery = $inc:
          'quantities.0.inOderQuantity'    : detail.basicQuantity
          'quantities.0.availableQuantity' : -detail.basicQuantity

        console.log updateQuery
        Schema.products.update product._id, updateQuery

    orderUpdate = $set:
      orderStatus    : Enums.getValue('OrderStatus', 'exportConfirm')
      export         : Meteor.userId()
      exportConfirmAt: new Date()
    Schema.orders.update orderFound._id, orderUpdate

  orderSuccessConfirm: (orderId, success = true)->
    user = Meteor.users.findOne(Meteor.userId())
    return {valid: false, error: 'user not found!'} unless user

    orderQuery =
      _id         : orderId
      merchant    : user.profile.merchant
      orderType   : Enums.getValue('OrderTypes', 'tracking')
      orderStatus : Enums.getValue('OrderStatus', 'exportConfirm')
    orderFound = Schema.orders.findOne orderQuery
    return {valid: false, error: 'order not found!'} unless orderFound

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
    return {valid: false, error: 'user not found!'} unless user

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
    return {valid: false, error: 'order not found!'} unless orderFound

    orderUpdate = $set:
      orderType   : Enums.getValue('OrderTypes', 'tracking')
      orderStatus : Enums.getValue('OrderStatus', 'exportConfirm')
    Schema.orders.update orderFound._id, orderUpdate

  orderImportConfirm: (orderId)->
    user = Meteor.users.findOne(Meteor.userId())
    return {valid: false, error: 'user not found!'} unless user

    orderQuery =
      _id         : orderId
      merchant    : user.profile.merchant
      orderType   : Enums.getValue('OrderTypes', 'fail')
      orderStatus : Enums.getValue('OrderStatus', 'fail')
    orderFound = Schema.orders.findOne orderQuery
    return {valid: false, error: 'order not found!'} unless orderFound

    for detail, detailIndex in orderFound.details
      if product = Schema.products.findOne(detail.product)
        updateQuery = $inc:
          'quantities.0.inOderQuantity': -detail.basicQuantity
          'quantities.0.availableQuantity':detail.basicQuantity
        Schema.products.update product._id, updateQuery

    orderUpdate = $set:
      orderStatus     : Enums.getValue('OrderStatus', 'importConfirm')
      import          : Meteor.userId()
      importConfirmAt : new Date()
    Schema.orders.update orderFound._id, orderUpdate

  orderFinishConfirm: (orderId)->
    user = Meteor.users.findOne(Meteor.userId())
    return {valid: false, error: 'user not found!'} unless user

    orderQuery =
      _id         : orderId
      merchant    : user.profile.merchant
      orderType   : {$in:[Enums.getValue('OrderTypes', 'success'), Enums.getValue('OrderTypes', 'fail')]}
      orderStatus : {$in:[Enums.getValue('OrderStatus', 'success'), Enums.getValue('OrderStatus', 'importConfirm')]}
    orderFound = Schema.orders.findOne orderQuery
    return {valid: false, error: 'order not found!'} unless orderFound

    customerFound = Schema.customers.findOne(orderFound.buyer)
    return {valid: false, error: 'customer not found!'} unless customerFound

    merchantFound = Schema.merchants.findOne(user.profile.merchant)
    return {valid: false, error: 'merchant not found!'} unless merchantFound

    if orderFound.orderType is Enums.getValue('OrderTypes', 'success')
      customerFound = Schema.customers.findOne(orderFound.buyer)
      return {valid: false, error: 'customer not found!'} unless customerFound

      transactionId = createTransaction(customerFound, orderFound)
      return {valid: false, error: 'customer not found!'} unless transactionId

      for orderDetail, detailIndex in orderFound.details
        if product = Schema.products.findOne({'units._id': orderDetail.productUnit})
          updateSubtractQuantityInProductUnit(product, orderDetail)

          if product.inventoryInitial
            combinedImports = findAllImport(orderDetail.product)
            updateSubtractQuantityInImport(orderFound, orderDetail, detailIndex, combinedImports)

      updateOrderQuery = $set:
        orderStatus : Enums.getValue('OrderStatus', 'finish')
        transaction : transactionId
        successDate : new Date()
#        orderCode   :"#{Helpers.orderCodeCreate(customerFound.saleBillNo)}/#{Helpers.orderCodeCreate(merchantFound.saleBillNo)}"

      if Schema.orders.update(orderFound._id, updateOrderQuery)
        buyer = Schema.customers.findOne(orderFound.buyer)
        optionNewOrder =
          notificationType: 'notify'
          sender          : Meteor.userId()
          receiver        : orderFound.seller
          group           : Enums.getObject('NotificationGroups')['newOrder'].value
          message         : "Nhân viên #{user.profile.name} xác nhận hoàn thành phiếu của khách hàng #{buyer.name}"
          reads           : [Meteor.userId()]
        Schema.notifications.insert(optionNewOrder)

        Schema.customers.update customerFound._id, {
          $inc: {saleBillNo: 0, transactionBillNo: 0}
          $addToSet:{orderSuccess: orderFound._id}
          $pull: {orderWaiting: orderFound._id}}
        Schema.merchants.update(merchantFound._id, $inc:{saleBillNo: 0, transactionBillNo: 0})


    else
      Schema.customers.update customerFound._id, $inc: {saleBillNo: -1}
      orderUpdate = $set:
        orderStatus : Enums.getValue('OrderStatus', 'finish')
      Schema.orders.update orderFound._id, orderUpdate
      Schema.customers.update orderFound.buyer, {$addToSet:{orderFailure: orderFound._id}, $pull: {orderWaiting: orderFound._id}}


Meteor.methods
  orderSuccessConfirmed: (orderId)->
    user = Meteor.users.findOne(Meteor.userId())
    return {valid: false, error: 'user not found!'} unless user

    orderQuery =
      _id       : orderId
      creator   : user._id
      merchant  : user.profile.merchant
      orderType : $in: [Enums.getValue('OrderTypes', 'export'),Enums.getValue('OrderTypes', 'import')]
    orderFound = Schema.orders.findOne orderQuery
    return {valid: false, error: 'order not found!'} unless orderFound

    if orderFound.paymentsDelivery is Enums.getValue('DeliveryTypes', 'delivery') and
      (orderFound.delivery.status is Enums.getValue('DeliveryStatus', 'unDelivered') or
        orderFound.delivery.status is Enums.getValue('DeliveryStatus', 'delivered'))
      return {valid: false, error: 'Delivery not finish!'}

    Schema.orders.update orderFound._id, $set: { orderType : Enums.getValue('OrderTypes', 'success') }
