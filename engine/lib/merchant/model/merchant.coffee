simpleSchema.merchants = new SimpleSchema
  name    : type: String, optional: true
  address : type: String, optional: true
  phone   : type: String, optional: true
  email   : type: String, optional: true
  version : type: simpleSchema.Version

  saleBillNo        : type: Number, defaultValue: 0 #số phiếu bán
  importBillNo      : type: Number, defaultValue: 0 #số phiếu nhap
  returnBillNo      : type: Number, defaultValue: 0 #số phiếu tra hang
  transactionBillNo : type: Number, defaultValue: 0 #số phiếu thu chi

  warehouses                 : type: [Object]
  "warehouses.$._id"         : simpleSchema.UniqueId
  "warehouses.$.createdAt"   : simpleSchema.DefaultCreatedAt
  "warehouses.$.isRoot"      : simpleSchema.DefaultBoolean(false)
  "warehouses.$.name"        : type: String
  "warehouses.$.description" : type: String, optional: true
  "warehouses.$.address"     : type: String, optional: true
  "warehouses.$.phone"       : type: String, optional: true

  merchantOptions                 : type: Object  , optional    : true
  merchantSummaries               : type: Object  , optional    : true
  "merchantSummaries.barcodeUsed" : type: [String], defaultValue: []

Schema.add 'merchants', "Merchant", class Merchant
  @getId: ->
    Meteor.users.findOne(Meteor.userId())?.profile.merchant