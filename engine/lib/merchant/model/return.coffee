simpleSchema.returns = new SimpleSchema
  merchant:
    type: String

  warehouse:
    type: String

  creator:
    type: String

  returnCode:
    type: String

  tabDisplay:
    type: String
    defaultValue: 'Trả hàng'

  discountCash:
    type: Number

  discountPercent:
    type: Number
    decimal: true

  totalPrice:
    type: Number

  finallyPrice:
    type: Number

  comment:
    type: String
    optional: true

  status:
    type: Number

  submitReturn:
    type: String
    optional: true

  returnMethods:
    type: Number
    optional: true

  allowDelete:
    type: Boolean
    defaultValue: true

  styles:
    type: String
    defaultValue: Helpers.RandomColor()
    optional: true

  version: { type: simpleSchema.Version }
#------------------------
  sale:
    type: String
    optional: true

  import:
    type: String
    optional: true

  timeLineSales:
    type: String
    optional: true

  timeLineImport:
    type: String
    optional: true
#------------------------
  customer:
    type: String
    optional: true

  distributor:
    type: String
    optional: true

  partner:
    type: String
    optional: true
#------------------------
  beforeDebtBalance:
    type: Number
    optional: true

  debtBalanceChange:
    type: Number
    optional: true

  latestDebtBalance:
    type: Number
    optional: true
#------------------------
  creatorName:
    type: String
    optional: true

  productSale:
    type: Number
    optional: true

  productQuality:
    type: Number
    optional: true

Schema.add 'returns', "Return", class Return
  @createBySale: (saleId)->
    return console.log("Phiếu bán hàng không tồn tại.") if !sale = Schema.sales.findOne({_id: saleId})
    return console.log("Không thể tạo phiếu trả hàng mới, phiếu trả hàng cũ chưa kết thúc.") if sale.status == false
    option =
      merchant       : sale.merchant
      warehouse      : sale.warehouse
      creator        : Meteor.userId()
      creatorName    : Meteor.user().emails[0].address
      sale           : sale._id
      comment        : 'Trả Hàng'
      returnCode     : "ramdom"
      productSale    : 0
      productQuality : 0
      discountCash   : 0
      discountPercent: 0
      totalPrice     : 0
      finallyPrice   : 0
      status         : 0
    option._id = Schema.returns.insert option
    Schema.sales.update sale._id, $set:{
      currentReturn : option._id
      returner      : Meteor.userId()
      status        : false
    }
    option


  @createByCustomer: (customer, myProfile)->
    if !myProfile then myProfile = Schema.userProfiles.findOne({user: Meteor.userId()})
    option =
      merchant       : myProfile.currentMerchant
      warehouse      : myProfile.currentWarehouse
      creator        : myProfile.user
      customer       : customer._id
      returnCode     : "ramdom"
      discountCash   : 0
      discountPercent: 0
      totalPrice     : 0
      finallyPrice   : 0
      status         : 0
      returnMethods  : 0
      tabDisplay     : Helpers.shortName2(customer.name)
      beforeDebtBalance: 0
      debtBalanceChange: 0
      latestDebtBalance: 0
    option._id = Schema.returns.insert option
    option

  @createByDistributor: (distributor, myProfile)->
    if !myProfile then myProfile = Schema.userProfiles.findOne({user: Meteor.userId()})
    option =
      merchant       : myProfile.currentMerchant
      warehouse      : myProfile.currentWarehouse
      creator        : myProfile.user
      distributor    : distributor._id
      returnCode     : "ramdom"
      discountCash   : 0
      discountPercent: 0
      totalPrice     : 0
      finallyPrice   : 0
      status         : 0
      returnMethods  : 1
      tabDisplay     : Helpers.shortName2(distributor.name)
      beforeDebtBalance: 0
      debtBalanceChange: 0
      latestDebtBalance: 0
    option._id = Schema.returns.insert option
    option