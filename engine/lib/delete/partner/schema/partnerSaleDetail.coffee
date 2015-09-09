simpleSchema.partnerSaleDetails = new SimpleSchema
  buildInProduct:
    type: String

  product:
    type: String
    optional: true

  quality:
    type: Number

  price:
    type: Number
    decimal: true
#----------------------------------------
  buildInProductUnit:
    type: String
    optional: true

  unit:
    type: String
    optional: true

  unitQuantity:
    type: Number
    optional: true
    decimal: true

  unitPrice:
    type: Number
    optional: true

  conversionQuantity:
    type: Number
    optional: true
#----------------------------------------
  partnerSales:
    type: String

  branchProduct:
    type: String
    optional: true

  productDetail:
    type: [Object]
    blackbox: true
    optional: true

  returnQuantity:
    type: Number
    optional: true

  discountCash:
    type: Number
    decimal: true
    defaultValue: 0

  discountPercent:
    type: Number
    decimal: true
    defaultValue: 0

  status:
    type: String
    defaultValue: 'unSubmit'

  styles:
    type: String
    defaultValue: Helpers.RandomColor()
  version: { type: simpleSchema.Version }

Schema.add 'partnerSaleDetails', "PartnerSaleDetails", class PartnerSaleDetails
  @findBy: (importId, warehouseId = null, merchantId = null)->


