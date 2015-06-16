Enums = Apps.Merchant.Enums
Enums.OrderType =
  created   : 0
  submitted : 1

Enums.paymentMethod =
  created   : 0
  submitted : 1

Enums.paymentsDelivery =
  created   : 0
  submitted : 1

Enums.DeliveryStatus =
  created  : 0
  delivered: 1
  succeed  : 2

simpleSchema.orders = new SimpleSchema
  orderName   : simpleSchema.DefaultString('ĐƠN HÀNG')
  seller      : simpleSchema.OptionalString
  buyer       : simpleSchema.OptionalString

  merchant        : simpleSchema.DefaultMerchant
  allowDelete     : simpleSchema.DefaultBoolean()
  creator         : simpleSchema.DefaultCreator
  version         : { type: simpleSchema.Version }

  profiles                    : type: Object , optional: true
  'profiles.description'      : simpleSchema.OptionalString
  'profiles.orderCode'        : simpleSchema.OptionalString
  'profiles.orderType'        : simpleSchema.DefaultNumber(Enums.OrderType.created)
  'profiles.paymentMethod'    : simpleSchema.DefaultNumber()
  'profiles.paymentsDelivery' : simpleSchema.DefaultNumber()
  'profiles.deliveryStatus'   : simpleSchema.OptionalNumber

  'profiles.discountCash'     : simpleSchema.DefaultNumber()
  'profiles.depositCash'      : simpleSchema.DefaultNumber()
  'profiles.totalPrice'       : simpleSchema.DefaultNumber()
  'profiles.finalPrice'       : simpleSchema.DefaultNumber()

  details                   : type: [Object], defaultValue: []
  'details.$._id'           : simpleSchema.UniqueId
  'details.$.product'       : type: String
  'details.$.productUnit'   : type: String
  'details.$.quality'       : {type: Number, min: 0}
  'details.$.price'         : {type: Number, min: 0}
  'details.$.discountCash'  : simpleSchema.DefaultNumber()
  'details.$.basicQuality'  : {type: Number, min: 0}
  'details.$.returnQuality' : simpleSchema.DefaultNumber()

  deliveries                     : type: Object , optional: true
  'deliveries.shipper'           : simpleSchema.OptionalString
  'deliveries.buyer'             : simpleSchema.OptionalString
  'deliveries.deliveryCode'      : simpleSchema.OptionalString
  'deliveries.contactName'       : simpleSchema.OptionalString
  'deliveries.description'       : simpleSchema.OptionalString
  'deliveries.contactPhone'      : simpleSchema.OptionalString
  'deliveries.deliveryAddress'   : simpleSchema.OptionalString
  'deliveries.deliveryDate'      : simpleSchema.OptionalString
  'deliveries.transportationFee' : simpleSchema.OptionalNumber
  'deliveries.createdAt'         : simpleSchema.DefaultCreatedAt

Schema.add 'orders', "Order", class Order
  @transform: (doc) ->
    doc.remove = -> Schema.orders.remove(@_id, callback) if @allowDelete

    doc.searchPrice = (productUnitId) ->

    doc.changeBuyer = (customerId, callback)->
      if customer = Schema.customers.findOne(customerId)
        option = $set:{ buyer: customer._id, orderName: Helpers.shortName2(customer.name) }
        Schema.orders.update @_id, option, callback

    doc.changePaymentsDelivery = (paymentsDeliveryId, callback)->
      option = $set:{"profiles.paymentsDelivery": paymentsDeliveryId}
      Schema.orders.update @_id, option, callback

    doc.changePaymentMethod = (paymentMethodId, callback)->
      option = $set:{'profiles.paymentMethod': paymentMethodId}
      option.$set['profiles.depositCash'] =
        if option.$set['profiles.paymentMethod'] is 0 then @profiles.finalPrice
        else if option.$set['profiles.paymentMethod'] is 1 then 0
      Schema.orders.update @_id, option, callback

    doc.changeDepositCash = (depositCash, callback) ->
      option = $set:{'profiles.depositCash': Math.abs(depositCash)}
      option.$set['profiles.paymentMethod'] = if option.$set['profiles.depositCash'] > 0 then 0 else 1
      Schema.orders.update @_id, option, callback

    doc.changeDescription = (description, callback)->
      option = $set:{'profiles.description': description}
      Schema.orders.update @_id, option, callback

    doc.recalculatePrices = (newId, newQuality, newPrice) ->
      totalPrice = 0
      for detail in @details
        if detail._id is newId
          totalPrice += newQuality * newPrice
        else
          totalPrice += detail.quality * detail.price

      totalPrice: totalPrice
      finalPrice: totalPrice - @discountCash


    doc.addDetail = (productUnitId, quality = 1, price = 1, callback) ->
      return console.log('Khong tim thay Product') if !product = Schema.products.findOne({'units._id': productUnitId})
      return console.log('Khong tim thay ProductUnit') if !productUnit = _.findWhere(product.units, {_id: productUnitId})
      return console.log('Price not found..') if !price = price ? product.searchPrice(productUnitId)?.sale
      return console.log("Price invalid (#{price})") if price < 0
      return console.log("Quality invalid (#{quality})") if quality < 1

      detailFindQuery = {product: product._id, productUnit: productUnitId, price: price}
      detailFound = _.findWhere(@details, detailFindQuery)
      console.log doc.details, detailFindQuery, detailFound

      console.log productUnit.conversion
      if detailFound
        detailIndex = _.indexOf(@details, detailFound)
        updateQuery = {$inc:{}}
        updateQuery.$inc["details.#{detailIndex}.quality"] = quality
        updateQuery.$inc["details.#{detailIndex}.basicQuality"] = quality * productUnit.conversion
        recalculationOrder(@_id) if Schema.orders.update(@_id, updateQuery, callback)

      else
        detailFindQuery.quality = quality
        detailFindQuery.basicQuality = quality * productUnit.conversion
        recalculationOrder(@_id) if Schema.orders.update(@_id, { $push: {details: detailFindQuery} }, callback)

    doc.editDetail = (detailId, quality, price, callback) ->
      for instance, i in @details
        if instance._id is detailId
          updateIndex = i
          updateInstance = instance
          conversionUnit = updateInstance.basicQuality/updateInstance.quality
      return console.log 'OrderDetailRow not found..' if !updateInstance

      newSummary = @recalculatePrices(detailId, quality, price)

      predicate = $set:{}
      predicate.$set["totalPrice"] = newSummary.totalPrice
      predicate.$set["finalPrice"] = newSummary.finalPrice
      predicate.$set["details.#{updateIndex}.quality"] = quality
      predicate.$set["details.#{updateIndex}.basicQuality"] = quality * conversionUnit
      predicate.$set["details.#{updateIndex}.price"] = price
      Schema.orders.update @_id, predicate, callback

    doc.removeDetail = (detailId, callback) ->
      return console.log('Order không tồn tại.') if (!self = Schema.orders.findOne doc._id)
      return console.log('OrderDetail không tồn tại.') if (!detailFound = _.findWhere(self.details, {_id: detailId}))
      detailIndex = _.indexOf(self.details, detailFound)
      removeDetailQuery = { $pull:{} }
      removeDetailQuery.$pull.details = self.details[detailIndex]
      recalculationOrder(self._id) if Schema.orders.update(self._id, removeDetailQuery, callback)



    doc.submit = ->
      return console.log('Order không tồn tại.') if (!self = Schema.orders.findOne doc._id)
      return console.log('Order đã Submit') if self.orderType isnt Enum.orderType.created

      for detail, detailIndex in self.details
        product = Document.Product.findOne({'units._id': detail.productUnit})
        return console.log('Khong tim thay Product') if !product
        productUnit = _.findWhere(product.units, {_id: detail.productUnit})
        return console.log('Khong tim thay ProductUnit') if !productUnit
#      Meteor.call 'orderSubmit', self._id

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

      deliveryLastIndex = self.deliveries.length - 1
      deliveryReceiptUpdate = {$set:{}}
      deliveryReceiptUpdate.$set['deliveries.'+deliveryLastIndex +'.shipper'] = staffId
      Schema.orders.update self._id, deliveryReceiptUpdate, callback

    doc.deliverySucceed = (staffId = Meteor.userId(), callback)->
      deliveryLastIndex = self.deliveries.length - 1
      deliveryReceiptUpdate = {$unset:{}}
      deliveryReceiptUpdate.$unset['deliveries.'+deliveryLastIndex +'.shipper'] = ""
      Schema.orders.update self._id, deliveryReceiptUpdate, callback

  @insert: (buyer, seller, tabDisplay, description, callback) ->
    newOrder = {}
    newOrder.buyer = buyer if buyer
    newOrder.seller= seller if seller
    Schema.orders.insert newOrder, callback


recalculationOrder = (orderId) ->
  orderFound = Schema.orders.findOne(orderId)
  totalPrice = 0
  (totalPrice += detail.quality * detail.price) for detail in orderFound.details
  finalPrice = totalPrice - orderFound.profiles.discountCash
  Schema.orders.update orderFound._id, $set:{'profiles.totalPrice': totalPrice, 'profiles.finalPrice': finalPrice}