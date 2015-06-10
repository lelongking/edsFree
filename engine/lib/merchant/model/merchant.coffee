simpleSchema.merchants = new SimpleSchema
  creator     : simpleSchema.DefaultCreator
  version     : {type: simpleSchema.Version }

  name:
    type: String
    optional: true #optional tren danh nghia, se phai dien vao trong buoc dang ky!

  address:
    type: String
    optional: true

  area:
    type: [String]
    optional: true

  merchantProfile:  type: Object, optional: true
  "merchantProfile.isActive"          : type: Boolean , defaultValue: false
  "merchantProfile.duration"          : type: Number  , defaultValue: 14
  "merchantProfile.accountLimit"      : type: Number  , defaultValue: 4
  "merchantProfile.accountNumberUsed" : type: Number  , defaultValue: 1
  "merchantProfile.activeEndDate"     : type: Date    , optional: true

  "merchantProfile.companyName"    : type: String, optional: true
  "merchantProfile.companyPhone"   : type: String, optional: true
  "merchantProfile.companyAddress" : type: String, optional: true
  "merchantProfile.companyEmail"   : type: String, optional: true


  warehouses                : type: [Object], defaultValue: [{}]
  "warehouses.$.name"       : type: String, defaultValue: 'Trụ Sở'
  "warehouses.$.description": type: String  , optional: true
  "warehouses._id"          : simpleSchema.UniqueId
  "warehouses.createdAt"    : simpleSchema.DefaultCreatedAt


  merchantSummary: type: Object, defaultValue: {}
  "merchantSummary.customerCount"    : type: Number  , defaultValue: 0
  "merchantSummary.distributorCount" : type: Number  , defaultValue: 0
  "merchantSummary.productCount"     : type: Number  , defaultValue: 0
  "merchantSummary.partnerCount"     : type: Number  , defaultValue: 0

  "merchantSummary.saleDayCount"         : type: Number  , defaultValue: 0
  "merchantSummary.importDayCount"       : type: Number  , defaultValue: 0
  "merchantSummary.deliveryDayCount"     : type: Number  , defaultValue: 0
  "merchantSummary.returnSaleDayCount"   : type: Number  , defaultValue: 0
  "merchantSummary.returnImportDayCount" : type: Number  , defaultValue: 0

  "merchantSummary.barcodeUsed" : type: [String], defaultValue: []

Schema.add 'merchants', "Merchant", class Merchant
  #  checkProductExpireDate: (value, merchantId)->
  #    if profile = Schema.userProfiles.findOne({user: Meteor.userId()})
  #      timeOneDay = 86400000
  #      tempDate = new Date
  #      currentDate = new Date(tempDate.getFullYear(), tempDate.getMonth(), tempDate.getDate())
  #      expireDate  = new Date(tempDate.getFullYear(), tempDate.getMonth(), tempDate.getDate() + value)
  #
  #      productDetails = Schema.productDetails.find({$and:[
  #          {merchant: merchantId}
  #          {expire:{$lte: expireDate}}
  #          {inStockQuality:{$gt: 0}}
  #        ]}).fetch()
  #
  #      for productDetail in productDetails
  #        product   = Schema.products.findOne(productDetail.product)
  #        warehouse = Schema.warehouses.findOne(productDetail.warehouse)
  #        date      = ((productDetail.expire).getTime() - currentDate.getTime())/timeOneDay
  #
  #        currentProduct = {
  #          _id   : productDetail._id
  #          name  : product.name
  #          day   : date
  #          place : warehouse.name }
  #        Notification.productExpire(currentProduct)

  addDefaultWarehouse: ->
    if Schema.warehouse.findOne({merchant: @id})
      option =
        merchant          : @id
        creator           : Meteor.userId()
        name              : 'Kho Chính'
        isRoot            : true
        checkingInventory : false
      option.parentMerchant = merchant.parent if merchant.parent
      option