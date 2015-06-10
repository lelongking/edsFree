importDetail = new SimpleSchema
  _id                : simpleSchema.UniqueId()
  product            : type: String
  productUnit        : type: String
  quality            : type: Number
  price              : type: Number
  expire             : type: Date, optional: true
  availableQuality   : simpleSchema.DefaultNumber()
  inOderQuality      : simpleSchema.DefaultNumber()
  inStockQuality     : simpleSchema.DefaultNumber()
  saleQuality        : simpleSchema.DefaultNumber()
  returnSaleQuality  : simpleSchema.DefaultNumber()
  importQuality      : simpleSchema.DefaultNumber()
  returnImportQuality: simpleSchema.DefaultNumber()

importSession = new SimpleSchema
  currentProduct:
    type: String
    optional: true

  currentUnit:
    type: String
    optional: true

  currentProvider:
    type: String
    optional: true

  currentQuality:
    type: Number
    optional: true

  currentImportPrice:
    type: Number
    optional: true

  currentPrice:
    type: Number
    optional: true

  currentExpire:
    type: Date
    optional: true

  latestDebtBalance:
    type: Number
    defaultValue: 0

  debtBalanceChange:
    type: Number
    defaultValue: 0

  beforeDebtBalance:
    type: Number
    defaultValue: 0

importProfile = new SimpleSchema
  tabDisplay :
    type: String
    defaultValue: 'Nhập kho'

  description:
    type: String
    optional: true

  totalPrice:
    type: Number
    defaultValue: 0

  deposit:
    type: Number
    defaultValue: 0

  debit:
    type: Number
    defaultValue: 0

  finish:
    type: Boolean
    defaultValue: false

  submitted:
    type: Boolean
    defaultValue: false

  systemTransaction:
    type: String
    optional: true

  status:
    type: String
    defaultValue: 'new'

simpleSchema.imports = new SimpleSchema
  merchant   : simpleSchema.DefaultMerchant()
  provider   : simpleSchema.OptionalString

  profiles:
    type: importProfile
    optional: true

  sessions:
    type: Object
    optional: true

  details:
    type: [importDetail]
    optional: true

  allowDelete: simpleSchema.DefaultBoolean()
  creator    : simpleSchema.DefaultCreator()
  version    : { type: simpleSchema.Version }


Schema.add 'imports', "Import", class Import
  @findBy: (importId, warehouseId = null, merchantId = null)->
    myProfile = Schema.userProfiles.findOne({user: Meteor.userId()})
    @schema.findOne({
      _id      : importId
      merchant : merchantId ? myProfile.currentMerchant
      warehouse: warehouseId ? myProfile.currentWarehouse
    })

  @myHistory: (creatorId, warehouseId = null, merchantId = null)->
    myProfile= Schema.userProfiles.findOne({user: Meteor.userId()})
    @schema.find({
      $and : [
        creator   : creatorId ? myProfile.user
        warehouse : warehouseId ? myProfile.currentWarehouse
        merchant  : merchantId ? myProfile.currentMerchant
        status    : {$nin: ['unSubmit']}
        $or : [{ finish : false }, { submitted : false}]
      ]
    })

  @createdNewBy: (description, distributor, partner, myProfile)->
    if !myProfile then myProfile = Schema.userProfiles.findOne({user: Meteor.userId()})
    importOption =
      parentMerchant: myProfile.parentMerchant
      merchant      : myProfile.currentMerchant
      warehouse     : myProfile.currentWarehouse
      creator       : myProfile.user

    if distributor
      importOption.distributor = distributor._id if distributor._id
      importOption.tabDisplay = Helpers.shortName2(distributor.name) if distributor.name

    if partner
      importOption.partner = partner._id if partner._id
      importOption.tabDisplay = Helpers.shortName2(partner.name) if partner.name

    importOption.description = description if description
    importOption._id = @schema.insert importOption

    if importOption._id then return importOption else return undefined



  @findHistory: (starDate, toDate, warehouseId) ->
    @schema.find({$and: [
      {warehouse: warehouseId, submitted: true}
      {'version.createdAt': {$gt: new Date(starDate.getFullYear(), starDate.getMonth(), starDate.getDate())}}
      {'version.createdAt': {$lt: new Date(toDate.getFullYear(), toDate.getMonth(), toDate.getDate()+1)}}
    ]}, {sort: {'version.createdAt': -1}})
