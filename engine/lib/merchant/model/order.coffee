Enums = Apps.Merchant.Enums

#------------ Models Order ------------
simpleSchema.orders = new SimpleSchema
  depositCash : simpleSchema.DefaultNumber()
  discountCash: simpleSchema.DefaultNumber()
  totalPrice  : simpleSchema.DefaultNumber()
  finalPrice  : simpleSchema.DefaultNumber()

  merchant    : simpleSchema.DefaultMerchant
  allowDelete : simpleSchema.DefaultBoolean()
  creator     : simpleSchema.DefaultCreator
  version     : { type: simpleSchema.Version }

  orderType        : type: Number, defaultValue: Enums.getValue('OrderTypes', 'initialize')
  orderStatus      : type: Number, defaultValue: Enums.getValue('OrderStatus', 'initialize')
  paymentMethod    : type: Number, defaultValue: Enums.getValue('PaymentMethods', 'direct')
  paymentsDelivery : type: Number, defaultValue: Enums.getValue('DeliveryTypes', 'direct')

  buyer       : type: String, optional: true
  dueDay      : type: Number, optional: true
  description : type: String, optional: true
  orderName   : type: String, defaultValue: 'ĐƠN HÀNG'

  orderCode        : type: String, optional: true
  billNoOfBuyer    : type: String, optional: true
  billNoOfMerchant : type: String, optional: true

#nhan vien tao phieu
  seller          : simpleSchema.DefaultCreator
  sellerConfirmAt : type: Date, optional: true
#ke toan xac nhan phieu
  accounting          : type: String  , optional: true
  accountingConfirmAt : type: Date, optional: true
#xac nhan xuat kho khi giao hang
  export          : type: String  , optional: true
  exportConfirmAt : type: Date    , optional: true
#xac nhan nhap kho khi giao hang that bai
  import          : type: String  , optional: true
  importConfirmAt : type: Date    , optional: true
#ngay xac nhan
  transaction : type: String  , optional: true
  saleDate    : type: Date, optional: true
  shipperDate : type: Date, optional: true
  successDate : type: Date, optional: true

  details                   : type: [Object], defaultValue: []
  'details.$._id'           : simpleSchema.UniqueId
  'details.$.product'       : type: String
  'details.$.productUnit'   : type: String

  'details.$.quality'       : type: Number, min: 0
  'details.$.price'         : type: Number, min: 0
  'details.$.discountCash'  : simpleSchema.DefaultNumber()
  'details.$.isExport'      : simpleSchema.DefaultBoolean(false)
  'details.$.importIsValid' : type: Boolean, optional: true

  'details.$.conversion'    : type: Number, min: 1
  'details.$.basicQuantity' : type: Number, min: 0
  'details.$.basicQuantityReturn'   : type: Number, min: 0
  'details.$.basicQuantityAvailable': type: Number, min: 0 #basicQuantity - basicReturnQuantity

  'details.$.basicImportQuantity'      : type: Number, min: 0
  'details.$.basicImportQuantityDebit' : type: Number, min: 0 #(basicImportQuantity - basicReturnQuantity) if basicImportQuantity > basicReturnQuantity
  'details.$.basicImportQuantityReturn': type: Number, min: 0 #(basicReturnQuantity - basicImportQuantity) if basicImportQuantity < basicReturnQuantity

#------------ ImportDetail ------------
  'details.$.imports': type: [Object], optional: true #Import Detail
  'details.$.imports.$._id'         : type: String, optional: true
  'details.$.imports.$.detailId'    : type: String, optional: true
  'details.$.imports.$.product'     : type: String, optional: true
  'details.$.imports.$.productUnit' : type: String, optional: true
  'details.$.imports.$.provider'    : type: String, optional: true

  'details.$.imports.$.conversion'  : type: Number, min: 1
  'details.$.imports.$.quality'     : type: Number, min: 0
  'details.$.imports.$.basicQuantity'         : type: Number, min: 0
  'details.$.imports.$.basicQuantityReturn'   : type: Number, min: 0
  'details.$.imports.$.basicQuantityAvailable': type: Number, min: 0

  'details.$.imports.$.price'       : type: Number
  'details.$.imports.$.note'        : type: String, optional: true
  'details.$.imports.$.createdAt'   : type: Date


#khi co xac nhan thu tien va xuat kho, moi co the tiep tuc chuyen sang che do di giao hang
  delivery                     : type: Object , optional: true
  'delivery.deliveryCode'      : simpleSchema.OptionalString
  'delivery.status'            : simpleSchema.DefaultNumber(Enums.getValue('DeliveryStatus', 'unDelivered'))
  'delivery.shipper'           : simpleSchema.OptionalString
  'delivery.createdAt'         : simpleSchema.DefaultCreatedAt

  'delivery.contactName'       : simpleSchema.OptionalString
  'delivery.contactPhone'      : simpleSchema.OptionalString
  'delivery.deliveryAddress'   : simpleSchema.OptionalString
  'delivery.deliveryDate'      : simpleSchema.OptionalString
  'delivery.description'       : simpleSchema.OptionalString
  'delivery.transportationFee' : simpleSchema.OptionalNumber




#------------ Method Order ------------
Schema.add 'orders', "Order", class Order
  @transform: (doc) ->
    doc.remove = ->
      Schema.orders.remove @_id if @allowDelete

    doc.changeDueDay = (dueDay, callback)->
      return console.log('Order da xac nhan') unless _.contains(statusCantEdit, doc.orderStatus)
      Schema.orders.update @_id, $set:{dueDay: Math.abs(Number(dueDay))}, callback

    doc.changeBuyer = (customerId, callback)->
      return console.log('Order da xac nhan') unless _.contains(statusCantEdit, doc.orderStatus)
      customer = Schema.customers.findOne(customerId)
      if customer
        totalPrice = 0; discountCash = 0
        predicate = $set:{ buyer: customer._id, orderName: Helpers.shortName2(customer.name) }

        for instance, index in @details
          product = Schema.products.findOne(instance.product)
          productPrice  = product.getPrice(customer._id, 'sale')
          totalPrice   += instance.quality * productPrice
          discountCash += instance.quality * instance.discountCash
          predicate.$set["details.#{index}.price"] = productPrice

        predicate.$set.totalPrice   = totalPrice
        predicate.$set.discountCash = discountCash
        predicate.$set.finalPrice   = totalPrice - discountCash
        Schema.orders.update @_id, predicate, callback

    doc.changePaymentsDelivery = (paymentsDeliveryId)->
      return console.log('Order da xac nhan') unless _.contains(statusCantEdit, doc.orderStatus)
      option = $set:{
        'paymentsDelivery': paymentsDeliveryId
        'delivery.status' : paymentsDeliveryId
        'delivery.shipper': @creator
      }
      Schema.orders.update @_id, option

    doc.changePaymentMethod = (paymentMethodId)->
      return console.log('Order da xac nhan') unless _.contains(statusCantEdit, doc.orderStatus)
      option = $set:{'paymentMethod': paymentMethodId}
      option.$set['depositCash'] =
        if option.$set['paymentMethod'] is 0 then @finalPrice
        else if option.$set['paymentMethod'] is 1 then 0
      Schema.orders.update @_id, option

    doc.changeDepositCash = (depositCash, callback) ->
      return console.log('Order da xac nhan') unless _.contains(statusCantEdit, doc.orderStatus)
      option = $set:{'depositCash': Math.abs(depositCash)}
      option.$set.paymentMethod = if option.$set.depositCash > 0 then 0 else 1
      Schema.orders.update @_id, option

    doc.changeDiscountCash = (discountCash) ->
      return console.log('Order da xac nhan') unless _.contains(statusCantEdit, doc.orderStatus)
      discountCash = if Math.abs(discountCash) > doc.totalPrice then doc.totalPrice else Math.abs(discountCash)

      orderUpdate = $set:{discountCash: discountCash, finalPrice: (doc.totalPrice - discountCash)}
      orderUpdate.$set["details.#{index}.discountCash"] = 0 for orderDetail, index in doc.details
      Schema.orders.update doc._id, orderUpdate

    doc.changeDescription = (description, callback)->
      return console.log('Order da xac nhan') unless _.contains(statusCantEdit, doc.orderStatus)
      option = $set:{'description': description}
      Schema.orders.update @_id, option

    doc.recalculatePrices = (newId, newQuantity, newPrice) ->
      totalPrice = 0
      for detail in @details
        if detail._id is newId
          totalPrice += newQuantity * ((if newPrice then newPrice else detail.price) - detail.discountCash)
        else
          totalPrice += detail.quality * (detail.price - detail.discountCash)

      totalPrice: totalPrice
      finalPrice: totalPrice - @discountCash


    doc.addDetail = (productUnitId, quality = 1) ->
      return console.log('Order da xac nhan') unless _.contains(statusCantEdit,doc.orderStatus)

      product = Schema.products.findOne({'units._id': productUnitId})
      return console.log('Khong tim thay Product') if !product

      productUnit = _.findWhere(product.units, {_id: productUnitId})
      return console.log('Khong tim thay ProductUnit') if !productUnit

      price = product.getPrice(@buyer, 'sale')
      return console.log('Price not found..') if price is undefined

      return console.log("Price invalid (#{price})") if price < 0
      return console.log("Quantity invalid (#{quality})") if quality < 1

      detailFindQuery = {product: product._id, productUnit: productUnitId, price: price}
      detailFound  = _.findWhere(@details, detailFindQuery)
      basicQuantity = quality * productUnit.conversion

      if detailFound
        detailIndex = _.indexOf(@details, detailFound)
        updateQuery = {$inc:{}}
        updateQuery.$inc["details.#{detailIndex}.quality"]      = quality
        updateQuery.$inc["details.#{detailIndex}.basicQuantity"] = basicQuantity
        updateQuery.$inc["details.#{detailIndex}.basicQuantityAvailable"]   = basicQuantity
        updateQuery.$inc["details.#{detailIndex}.basicImportQuantityDebit"] = basicQuantity
        recalculationOrder(@_id) if Schema.orders.update(@_id, updateQuery)

      else
        detailFindQuery.importIsValid         = false
        detailFindQuery.quality               = quality
        detailFindQuery.conversion            = productUnit.conversion
        detailFindQuery.basicQuantity          = basicQuantity
        detailFindQuery.basicQuantityAvailable = basicQuantity
        detailFindQuery.basicQuantityReturn    = 0

        detailFindQuery.basicImportQuantity       = 0
        detailFindQuery.basicImportQuantityDebit  = basicQuantity
        detailFindQuery.basicImportQuantityReturn = 0
        recalculationOrder(@_id) if Schema.orders.update(@_id, { $push: {details: detailFindQuery} })

    doc.editDetail = (detailId, quality, discountCash, price, callback) ->
      return console.log('Order da xac nhan') unless _.contains(statusCantEdit, doc.orderStatus)

      for instance, i in @details
        if instance._id is detailId
          updateIndex = i
          updateInstance = instance
          break
      return console.log 'OrderDetailRow not found..' if !updateInstance

      predicate = $set:{}
      predicate.$set["details.#{updateIndex}.discountCash"] = discountCash if discountCash isnt undefined
      predicate.$set["details.#{updateIndex}.price"] = price if price isnt undefined

      if quality isnt undefined
        predicate.$set["details.#{updateIndex}.quality"] = quality
        predicate.$set["details.#{updateIndex}.basicQuantity"] = quality * updateInstance.conversion
        predicate.$set["details.#{updateIndex}.basicQuantityAvailable"]   = quality * updateInstance.conversion
        predicate.$set["details.#{updateIndex}.basicImportQuantityDebit"] = quality * updateInstance.conversion

      if _.keys(predicate.$set).length > 0
        recalculationOrder(@_id) if Schema.orders.update(@_id, predicate)

    doc.removeDetail = (detailId, callback) ->
      return console.log('Order da xac nhan') unless _.contains(statusCantEdit, doc.orderStatus)
      return console.log('Order không tồn tại.') if (!self = Schema.orders.findOne doc._id)
      return console.log('OrderDetail không tồn tại.') if (!detailFound = _.findWhere(self.details, {_id: detailId}))
      detailIndex = _.indexOf(self.details, detailFound)
      removeDetailQuery = { $pull:{} }
      removeDetailQuery.$pull.details = self.details[detailIndex]
      recalculationOrder(self._id) if Schema.orders.update(self._id, removeDetailQuery)

    doc.orderConfirm = ->
      return console.log('Order da xac nhan') unless _.contains(statusCantEdit, doc.orderStatus)
      return console.log('customer not found') unless @buyer
      orderId = @_id

      for productId, details of _.groupBy(@details, (item) -> item.product)
        if !product = Schema.products.findOne(productId)
          (console.log('product not Found'); return)

        availableQuantity = product.quantities[0].availableQuantity ? 0
        for orderDetail in details
          saleQuantity  = 0 unless saleQuantity
          saleQuantity += orderDetail.basicQuantity

        if product.inventoryInitial and (availableQuantity - saleQuantity) < 0
          console.log('product quality nho'); return

      Meteor.call 'orderSellerConfirm', orderId, (error, result) ->
        console.log error, result, 'sellerConfirm'
        unless Schema.orders.findOne({
          merchant    : Merchant.getId()
          orderType   : Enums.getValue('OrderTypes', 'initialize')
          orderStatus : Enums.getValue('OrderStatus', 'initialize')
        }) then Order.insert()

        if User.hasManagerRoles
          Meteor.call 'orderAccountConfirm', orderId, (error, result) ->
            Meteor.call 'orderExportConfirm', orderId, (error, result) ->


    doc.addDelivery = (option, callback) ->
      return console.log('Order không tồn tại.') if (!self = Schema.orders.findOne doc._id)
      return console.log('Customer không tồn tại.') if (!customer = Document.Customer.findOne(self.buyer))
      return console.log('Delivery tồn tại.') if self.deliveryStatus

      addDeliver = {$push: {}}
      addDeliver.description        = option.description if Math.check(option.deliveryDate, String)
      addDeliver.deliveryDate       = option.deliveryDate if Math.check(option.deliveryDate, Date)
      addDeliver.contactName        = option.name ? customer.name
      addDeliver.contactPhone       = option.phone ? customer.phone
      addDeliver.deliveryAddress    = option.address ? customer.address
      addDeliver.transportationFee  = 0
      addDeliver.createdAt          = new Date()

      Schema.orders.update self._id, addDeliver, callback


    doc.deliveryReceipt = (staffId = Meteor.userId(), callback)->
      return console.log('Order không tồn tại.') if (!self = Schema.orders.findOne doc._id)
      return console.log('Delivery tồn tại.') unless self.deliveryStatus
      return console.log('Delivery đang được giao.') if self.deliveryStatus isnt Enum.created
      return console.log('Staff không tồn tại.') if !@Meteor.users.findOne(staffId)

      deliveryLastIndex = self.delivery.length - 1
      deliveryReceiptUpdate = {$set:{}}
      deliveryReceiptUpdate.$set['delivery.'+deliveryLastIndex +'.shipper'] = staffId
      Schema.orders.update self._id, deliveryReceiptUpdate, callback

    doc.deliverySucceed = (staffId = Meteor.userId(), callback)->
      deliveryLastIndex = self.delivery.length - 1
      deliveryReceiptUpdate = {$unset:{}}
      deliveryReceiptUpdate.$unset['delivery.'+deliveryLastIndex +'.shipper'] = ""
      Schema.orders.update self._id, deliveryReceiptUpdate, callback

  @insert: (buyer, seller, tabDisplay, description, callback) ->
    newOrder = {}
    newOrder.buyer       = buyer if buyer
    newOrder.seller      = seller if seller
    newOrder.description = description if description
    newOrder.orderName   = Helpers.shortName2(tabDisplay) if tabDisplay

    orderId = Schema.orders.insert newOrder, callback
    Meteor.users.update(Meteor.userId(), {$set: {'sessions.currentOrder': orderId}})
    return orderId

  @findNotSubmitted: ->
    Schema.orders.find({
      seller      : Meteor.userId()
      merchant    : Merchant.getId()
      orderType   : Enums.getValue('OrderTypes', 'initialize')
      orderStatus : Enums.getValue('OrderStatus', 'initialize')
    })

  @setSession: (orderId) ->
    Meteor.users.update(Meteor.userId(), {$set: {'sessions.currentOrder': orderId}})

recalculationOrder = (orderId) ->
  if orderFound = Schema.orders.findOne(orderId)
    totalPrice = 0; discountCash = 0
    for detail in orderFound.details
      totalPrice   += detail.quality * detail.conversion * detail.price
      discountCash += detail.quality * detail.conversion * detail.discountCash
    Schema.orders.update orderFound._id, $set:{
      totalPrice    : totalPrice
      discountCash  : discountCash
      finalPrice    : totalPrice - discountCash
    }

statusCantEdit = [
  Enums.getValue('OrderStatus', 'initialize')
  Enums.getValue('OrderStatus', 'sellerConfirm')
]