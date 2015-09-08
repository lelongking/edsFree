Enums = Apps.Merchant.Enums
simpleSchema.groups = new SimpleSchema
  name        : type: String, index: 1
  groupType   : type: String, defaultValue: Enums.getValue('GroupTypes', 'product')
  description : type: String, optional: true
  owners      : type: [String], defaultValue: []

  staff       : type: String  , optional: true
  priceBook   : type: String  , optional: true
  totalCash   : type: Number, defaultValue: 0

  nameSearch  : simpleSchema.searchSource('name')
  isBase      : simpleSchema.BooleanNotUpdate(false)
  allowDelete : simpleSchema.DefaultBoolean()
  merchant    : simpleSchema.DefaultMerchant
  creator     : simpleSchema.DefaultCreator
  version     : { type: simpleSchema.Version }

Schema.add 'groups', "Group", class Group
  @transform: (doc) ->
  @insert: (name)->
