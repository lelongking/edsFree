simpleSchema.orders = new SimpleSchema
  parentMerchant:
    type: String

  merchant:
    type: String

  warehouse:
    type: String

  creator:
    type: String
    optional: true

  seller:
    type: String
    optional: true

  buyer:
    type: String
    optional: true

  description:
    type: String
    optional: true

  tabDisplay:
    type: String
    defaultValue: 'New Order'

  orderCode:
    type: String
    optional: true

  productCount:
    type: Number
    defaultValue: 0

  saleCount:
    type: Number
    defaultValue: 0

  paymentsDelivery:
    type: Number
    defaultValue: 0

  paymentMethod:
    type: Number
    defaultValue: 1

  billDiscount:
    type: Boolean
    defaultValue: false

  discountCash:
    type: Number
    defaultValue: 0

  discountPercent:
    type: Number
    decimal: true
    defaultValue: 0

  totalPrice:
    type: Number
    defaultValue: 0

  finalPrice:
    type: Number
    defaultValue: 0

  deposit:
    type: Number
    defaultValue: 0

  debit:
    type: Number
    defaultValue: 0

  status:
    type: Number
    defaultValue: 0

  delivery:
    type: String
    optional: true

  styles:
    type: String
    defaultValue: Helpers.RandomColor()
    optional: true

  version: { type: simpleSchema.Version }

#----------------------
  currentProduct:
    type: String
    defaultValue: "null"

  currentUnit:
    type: String
    optional: true

  currentQuality:
    type: Number
    defaultValue: 0
    optional: true

  currentPrice:
    type: Number
    defaultValue: 0
    optional: true

  currentTotalPrice:
    type: Number
    defaultValue: 0
    optional: true

  currentDiscountCash:
    type: Number
    defaultValue: 0
    optional: true

  currentDiscountPercent:
    type: Number
    decimal: true
    defaultValue: 0
    optional: true

  currentDeposit:
    type: Number
    defaultValue: 0
    optional: true
#----------------------
  contactName:
    type: String
    optional: true

  contactPhone:
    type: String
    optional: true

  deliveryAddress:
    type: String
    optional: true

  deliveryDate:
    type: Date
    optional: true

  comment:
    type: String
    optional: true
#----------------------


Schema.add 'orders', "Order", class Order
  @findBy: (orderId, warehouseId = null, merchantId = null)->
    if myProfile= Schema.userProfiles.findOne({user: Meteor.userId()})
      @schema.findOne({
        _id      : orderId
        creator  : myProfile.user
        merchant : merchantId ? myProfile.currentMerchant
        warehouse: warehouseId ? myProfile.currentWarehouse
        status   : 0
      })

  @myHistory: (creatorId, warehouseId = null, merchantId = null)->
    if myProfile= Schema.userProfiles.findOne({user: Meteor.userId()})
      @schema.find({
        creator   : creatorId ? myProfile.user
        warehouse : warehouseId ? myProfile.currentWarehouse
        merchant  : merchantId ? myProfile.currentMerchant
        status    : 0
      })

  @createdNewBy: (buyer, myProfile = null)->
    if !myProfile then myProfile = Schema.userProfiles.findOne({user: Meteor.userId()})
    orderOption =
      parentMerchant: myProfile.parentMerchant
      merchant      : myProfile.currentMerchant
      warehouse     : myProfile.currentWarehouse
      creator       : myProfile.user
      seller        : myProfile.user
      tabDisplay    : if buyer then Helpers.shortName2(buyer.name) else 'PHIẾU BÁN HÀNG 01'

    orderOption.buyer = buyer._id if buyer?._id
    orderOption._id   = @schema.insert orderOption
    return orderOption


#  updateContactName     : (value)-> @schema.update(@id, {$set:{contactName:     value}})
#  updateContactPhone    : (value)-> @schema.update(@id, {$set:{contactPhone:    value}})
#  updateDeliveryAddress : (value)-> @schema.update(@id, {$set:{deliveryAddress: value}})
#  updateComment         : (value)-> @schema.update(@id, {$set:{comment:         value}})
  updateDeliveryDate    : (expire)->
    if expire > (new Date)
      expireDate = new Date(expire.getFullYear(), expire.getMonth(), expire.getDate())
      option = $set: {deliveryDate: expireDate}
    else
      option = $unset: {deliveryDate: true}
    @schema.update(@id, option)


