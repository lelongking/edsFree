simpleSchema.warehouses = new SimpleSchema
  parentMerchant:
    type: String
    optional: true

  merchant:
    type: String


  creator:
    type: String

  name:
    type: String

  isRoot:
    type: Boolean

  checkingInventory:
    type: Boolean

  inventory:
    type: String
    optional: true

  styles:
    type: String
    defaultValue: Helpers.RandomColor()
    optional: true

  location: { type: simpleSchema.Location, optional: true }
  version: { type: simpleSchema.Version }

Schema.add 'warehouses', "Warehouse", class Warehouse
  @findBy: (warehouseId, merchantId = null)->
    if !merchantId then myProfile= Schema.userProfiles.findOne({user: Meteor.userId()})
    @schema.findOne({
      _id      : warehouseId
      merchant : merchantId ? myProfile.currentMerchant
    })


  @newDefault: (context)->
    merchant = Schema.merchants.findOne(context.merchantId)
    warehouse = Schema.warehouses.find({merchant: context.merchantId}).count()
    if merchant and !warehouse
      option =
        parentMerchant    : context.parentMerchantId ? merchant.parent
        merchant          : merchant._id
        creator           : context.creator ? Meteor.userId()
        name              : context.name ? 'Kho Chính'
        isRoot            : true
        checkingInventory : false
      option.parentMerchant = merchant.parent if merchant.parent
      option

  @new: (merchantId)->
    merchant = Schema.merchants.findOne(merchantId)
    if merchant
      warehouseCount = Schema.warehouse.find({merchant: merchantId}).count()
      option =
        parentMerchant    : merchant.parent
        merchant          : merchant._id
        creator           : Meteor.userId()
        name              : "Kho Phu + #{warehouseCount}"
        isRoot            : false
        checkingInventory : false
      option.parentMerchant = merchant.parent if merchant.parent
      option

  addNewOrder: (option) ->
    option.merchant     = @data.merchant
    option.warehouse    = @id
    option.discountCash = 0
    option.productCount = 0
    option.saleCount    = 0
    option.totalPrice   = 0
    option.finalPrice   = 0
    option.deposit      = 0
    option.debit        = 0
    option.status       = 0
    option.checkingInventory  = false
    Schema.orders.insert option, (error, result)->
      console.log result; console.log error if error

  addImport: (option) ->
    return ('Mô Tả Không Được Đễ Trống') if !option.description
    option.merchant   = @data.merchant
    option.warehouse  = @id
    option.creator    = Meteor.userId()
    option.finish     = false
    Schema.imports.insert option, (error, result)-> console.log result; console.log error if error

