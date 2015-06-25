simpleSchema.providerGroups = new SimpleSchema
  name        : simpleSchema.StringUniqueIndex
  description : simpleSchema.OptionalString
  providerList: type: [String], defaultValue: []
  priceBook   : simpleSchema.OptionalString

  merchant    : simpleSchema.DefaultMerchant
  allowDelete : simpleSchema.DefaultBoolean()
  creator     : simpleSchema.DefaultCreator
  version     : { type: simpleSchema.Version }

Schema.add 'providerGroups', "ProviderGroup", class ProviderGroup
  @transform: (doc) ->