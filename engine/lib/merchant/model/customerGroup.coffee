simpleSchema.customerGroups = new SimpleSchema
  name        : simpleSchema.StringUniqueIndex
  description : simpleSchema.OptionalString
  customerList: type: [String], defaultValue: []
  priceBook   : simpleSchema.OptionalString

  merchant    : simpleSchema.DefaultMerchant
  allowDelete : simpleSchema.DefaultBoolean()
  creator     : simpleSchema.DefaultCreator
  version     : { type: simpleSchema.Version }

Schema.add 'customerGroups', "CustomerGroup", class CustomerGroup
  @transform: (doc) ->