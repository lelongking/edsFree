simpleSchema.merchants = new SimpleSchema
  creator     : simpleSchema.DefaultCreator
  version     : {type: simpleSchema.Version }

  name      : type: String  , optional: true #optional tren danh nghia, se phai dien vao trong buoc dang ky!
  address   : type: String  , optional: true
  area      : type: [String], optional: true
  totalCash : type: Number  , defaultValue: 0
  saleBallot  : type: Number  , defaultValue: 0 #số phiếu bán
  importBallot: type: Number  , defaultValue: 0 #số phiếu nhap

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
  @getId: -> Meteor.users.findOne(Meteor.userId())?.profile.merchant


