simpleSchema.productGroups = new SimpleSchema
  name        : simpleSchema.StringUniqueIndex
  description : simpleSchema.OptionalString
  productList: type: [String], defaultValue: []
  priceBook   : simpleSchema.OptionalString

  merchant    : simpleSchema.DefaultMerchant
  allowDelete : simpleSchema.DefaultBoolean()
  creator     : simpleSchema.DefaultCreator
  version     : { type: simpleSchema.Version }

Schema.add 'productGroups', "ProductGroup", class ProductGroup
  @transform: (doc) ->