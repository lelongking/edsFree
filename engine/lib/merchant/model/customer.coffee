customerProfile = new SimpleSchema


customerTransaction = new SimpleSchema


#----------------------------------------------------------------------------------------------------------------------
simpleSchema.customers = new SimpleSchema
  name        : simpleSchema.StringUniqueIndex
  description : simpleSchema.OptionalString
  group       : simpleSchema.OptionalString

  salePaid     : simpleSchema.DefaultNumber()
  saleDebt     : simpleSchema.DefaultNumber()
  saleTotalCash: simpleSchema.DefaultNumber()

  merchant    : simpleSchema.DefaultMerchant
  avatar      : simpleSchema.OptionalString
  allowDelete : simpleSchema.DefaultBoolean()
  creator     : simpleSchema.DefaultCreator
  version     : { type: simpleSchema.Version }

  profiles               : type: Object, optional: true
  'profiles.phone'       : simpleSchema.OptionalString
  'profiles.address'     : simpleSchema.OptionalString
  'profiles.gender'      : simpleSchema.DefaultBoolean()
  'profiles.billNo'      : simpleSchema.DefaultString('000')
  'profiles.areas'       : simpleSchema.OptionalStringArray

  'profiles.dateOfBirth' : simpleSchema.OptionalString
  'profiles.pronoun'     : simpleSchema.OptionalString
  'profiles.companyName' : simpleSchema.OptionalString
  'profiles.email'       : simpleSchema.OptionalString

  productTraded: type: [Object], defaultValue: []
  'productTraded.$.product'       : type: String
  'productTraded.$.productUnit'   : type: String
  'productTraded.$.saleQuality'   : type: Number
  'productTraded.$.returnQuality' : type: Number

Schema.add 'customers', "Customer", class Customer
  @transform: (doc) ->
    doc.remove = -> Schema.customers.remove(@_id, callback) if @allowDelete

  @insert: (name, description, callback) ->
    Schema.customers.insert({name: name, description: description}, callback)

  @splitName: (fullText) ->
    if fullText.indexOf("(") > 0
      namePart        = fullText.substr(0, fullText.indexOf("(")).trim()
      descriptionPart = fullText.substr(fullText.indexOf("(")).replace("(", "").replace(")", "").trim()
      return { name: namePart, description: descriptionPart }
    else
      return { name: fullText }

  @nameIsExisted: (name, merchant) ->
    existedQuery = {name: name, merchant: merchant}
    Schema.customers.findOne(existedQuery)