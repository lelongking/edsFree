Enums = Apps.Merchant.Enums

simpleSchema.orders = new SimpleSchema
  merchant    : simpleSchema.DefaultMerchant
  allowDelete : simpleSchema.DefaultBoolean()
  creator     : simpleSchema.DefaultCreator
  version     : { type: simpleSchema.Version }

  buyer       : type: String, optional: true
  orderName   : type: String, defaultValue: 'ĐƠN HÀNG'
  description : type: String, optional: true

  billNoOfBuyer     : type: String, optional: true
  billNoOfMerchant  : type: String, optional: true

  depositCash  : simpleSchema.DefaultNumber()
  discountCash : simpleSchema.DefaultNumber()
  totalPrice   : simpleSchema.DefaultNumber()
  finalPrice   : simpleSchema.DefaultNumber()

  orderCode        : simpleSchema.OptionalString
  orderType        : type: Number, defaultValue: Enums.getValue('OrderTypes', 'initialize')
  orderStatus      : type: Number, defaultValue: Enums.getValue('OrderStatus', 'initialize')
  paymentMethod    : type: Number, defaultValue: Enums.getValue('PaymentMethods', 'direct')
  paymentsDelivery : type: Number, defaultValue: Enums.getValue('DeliveryTypes', 'direct')
  dueDay           : type: Number, optional: true

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

  transaction     : type: String  , optional: true

  #ngay xac nhan
  saleDate    : type: Date, optional: true
  shipperDate : type: Date, optional: true
  successDate : type: Date, optional: true

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

  details                   : type: [Object], defaultValue: []
  'details.$._id'           : simpleSchema.UniqueId
  'details.$.product'       : type: String
  'details.$.productUnit'   : type: String
  'details.$.quality'       : type: Number, min: 0
  'details.$.price'         : type: Number, min: 0
  'details.$.basicQuality'  : type: Number, min: 0
  'details.$.conversion'    : type: Number, min: 1
  'details.$.discountCash'  : simpleSchema.DefaultNumber()
  'details.$.isExport'      : simpleSchema.DefaultBoolean(false)

  'details.$.import'                : type: [Object], optional: true
  'details.$.import.$._id'          : type: String  , optional: true
  'details.$.import.$.detailId'     : type: String  , optional: true
  'details.$.import.$.price'        : type: Number  , optional: true
  'details.$.import.$.quality'      : type: Number  , optional: true
  'details.$.import.$.basicQuality' : type: Number  , optional: true
  'details.$.import.$.note'         : type: String  , optional: true

  'details.$.return'               : type: [Object], optional: true
  'details.$.return.$._id'         : type: String
  'details.$.return.$.detailId'    : type: String
  'details.$.return.$.basicQuality': type: Number, optional: true

Schema.add 'orders', "Order", class Order
  @transform: (doc) ->
    doc.remove = -> Schema.orders.remove @_id if @allowDelete

    doc.changeDueDay = (dueDay, callback)->
      Schema.orders.update @_id, $set:{dueDay: Math.abs(Number(dueDay))}, callback

    doc.changeBuyer = (customerId, callback)->
      customer = Schema.customers.findOne(customerId)
      if customer
        totalPrice = 0; discountCash = 0
        predicate = $set:{ buyer: customer._id, orderName: Helpers.shortName2(customer.name) }

        for instance, index in @details
          product = Schema.products.findOne(instance.product)
          productPrice  = product.getPrice(instance.productUnit, customer._id, 'sale')
          totalPrice   += instance.quality * productPrice
          discountCash += instance.quality * instance.discountCash
          predicate.$set["details.#{index}.price"] = productPrice

        predicate.$set.totalPrice   = totalPrice
        predicate.$set.discountCash = discountCash
        predicate.$set.finalPrice   = totalPrice - discountCash
        Schema.orders.update @_id, predicate, callback

    doc.changePaymentsDelivery = (paymentsDeliveryId, callback)->
      option = $set:{
        'paymentsDelivery': paymentsDeliveryId
        'delivery.status' : paymentsDeliveryId
        'delivery.shipper': @creator
      }
      Schema.orders.update @_id, option, callback

    doc.changePaymentMethod = (paymentMethodId, callback)->
      option = $set:{'paymentMethod': paymentMethodId}
      option.$set['depositCash'] =
        if option.$set['paymentMethod'] is 0 then @finalPrice
        else if option.$set['paymentMethod'] is 1 then 0
      Schema.orders.update @_id, option, callback

    doc.changeDepositCash = (depositCash, callback) ->
      option = $set:{'depositCash': Math.abs(depositCash)}
      option.$set.paymentMethod = if option.$set.depositCash > 0 then 0 else 1
      Schema.orders.update @_id, option, callback

    doc.changeDiscountCash = (discountCash, callback) ->
      discountCash = if Math.abs(discountCash) > @totalPrice then @totalPrice else Math.abs(discountCash)
      Schema.orders.update @_id, $set:{discountCash: discountCash, finalPrice: (@totalPrice - discountCash)}, callback

    doc.changeDescription = (description, callback)->
      option = $set:{'description': description}
      Schema.orders.update @_id, option, callback

    doc.recalculatePrices = (newId, newQuality, newPrice) ->
      totalPrice = 0
      for detail in @details
        if detail._id is newId
          totalPrice += newQuality * ((if newPrice then newPrice else detail.price) - detail.discountCash)
        else
          totalPrice += detail.quality * (detail.price - detail.discountCash)

      totalPrice: totalPrice
      finalPrice: totalPrice - @discountCash


    doc.addDetail = (productUnitId, quality = 1, callback) ->
      product = Schema.products.findOne({'units._id': productUnitId})
      return console.log('Khong tim thay Product') if !product

      productUnit = _.findWhere(product.units, {_id: productUnitId})
      return console.log('Khong tim thay ProductUnit') if !productUnit

      price = product.getPrice(productUnitId, @buyer, 'sale')
      return console.log('Price not found..') if price is undefined

      return console.log("Price invalid (#{price})") if price < 0
      return console.log("Quality invalid (#{quality})") if quality < 1

      detailFindQuery = {product: product._id, productUnit: productUnitId, price: price}
      detailFound = _.findWhere(@details, detailFindQuery)

      if detailFound
        detailIndex = _.indexOf(@details, detailFound)
        updateQuery = {$inc:{}}
        updateQuery.$inc["details.#{detailIndex}.quality"]      = quality
#        updateQuery.$inc["details.#{detailIndex}.conversion"]   = productUnit.conversion
        updateQuery.$inc["details.#{detailIndex}.basicQuality"] = quality * productUnit.conversion
        recalculationOrder(@_id) if Schema.orders.update(@_id, updateQuery, callback)
      else
        detailFindQuery.quality      = quality
        detailFindQuery.conversion   = productUnit.conversion
        detailFindQuery.basicQuality = quality * productUnit.conversion
        recalculationOrder(@_id) if Schema.orders.update(@_id, { $push: {details: detailFindQuery} }, callback)

    doc.editDetail = (detailId, quality, discountCash, price, callback) ->
      for instance, i in @details
        if instance._id is detailId
          updateIndex = i
          updateInstance = instance
          break
      return console.log 'OrderDetailRow not found..' if !updateInstance

      predicate = $set:{}
      predicate.$set["details.#{updateIndex}.discountCash"] = discountCash  if discountCash isnt undefined
      predicate.$set["details.#{updateIndex}.price"] = price if price isnt undefined

      if quality isnt undefined
        predicate.$set["details.#{updateIndex}.quality"] = quality
        predicate.$set["details.#{updateIndex}.basicQuality"] = quality * updateInstance.conversion

      if _.keys(predicate.$set).length > 0
        recalculationOrder(@_id) if Schema.orders.update(@_id, predicate, callback)

    doc.removeDetail = (detailId, callback) ->
      return console.log('Order không tồn tại.') if (!self = Schema.orders.findOne doc._id)
      return console.log('OrderDetail không tồn tại.') if (!detailFound = _.findWhere(self.details, {_id: detailId}))
      detailIndex = _.indexOf(self.details, detailFound)
      removeDetailQuery = { $pull:{} }
      removeDetailQuery.$pull.details = self.details[detailIndex]
      recalculationOrder(self._id) if Schema.orders.update(self._id, removeDetailQuery, callback)

    doc.orderConfirm = ->
      return console.log('customer not found') unless @buyer
      orderId = @_id
      for detail in @details
        if product = Schema.products.findOne(detail.product)
          for unit in product.units
            if unit._id is detail.productUnit
              crossAvailable = (unit.quality.availableQuality - detail.basicQuality)/unit.conversion
              if product.inventoryInitial and crossAvailable < 0
                console.log('product quality nho'); return
        else
          console.log('product not Found'); return

        Meteor.call 'orderSellerConfirm', orderId, (error, result) ->
          console.log error, result, 'sellerConfirm'
          unless Schema.orders.findOne({
            merchant    : Merchant.getId()
            orderType   : Enums.getValue('OrderTypes', 'initialize')
            orderStatus : Enums.getValue('OrderStatus', 'initialize')
          }) then Order.insert()

#          Meteor.call 'orderAccountingConfirmed', orderId, (error, result) ->
#            console.log result, 'accounting'
#            Meteor.call 'orderExportConfirmed', orderId, (error, result) ->
#              console.log result, 'export'
#              Meteor.call 'orderSuccessConfirmed', orderId, (error, result) ->
#                console.log result, 'success'


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
      totalPrice   += detail.quality * detail.price
      discountCash += detail.quality * detail.discountCash
    Schema.orders.update orderFound._id, $set:{
      totalPrice    : totalPrice
      discountCash  : discountCash
      finalPrice    : totalPrice - discountCash
    }