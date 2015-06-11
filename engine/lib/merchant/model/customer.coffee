customerProfile = new SimpleSchema
  address     : simpleSchema.OptionalString
  phone       : simpleSchema.OptionalString
  dateOfBirth : simpleSchema.OptionalString
  pronoun     : simpleSchema.OptionalString
  companyName : simpleSchema.OptionalString
  email       : simpleSchema.OptionalString

customerTransaction = new SimpleSchema
  salePaid     : simpleSchema.DefaultNumber()
  saleDebt     : simpleSchema.DefaultNumber()
  saleTotalCash: simpleSchema.DefaultNumber()

#----------------------------------------------------------------------------------------------------------------------
simpleSchema.customers = new SimpleSchema
  name        : simpleSchema.StringUniqueIndex
  description : simpleSchema.OptionalString

  gender      : simpleSchema.DefaultBoolean()
  avatar      : simpleSchema.OptionalString
  areas       : simpleSchema.OptionalStringArray

  merchant    : simpleSchema.DefaultMerchant
  allowDelete : simpleSchema.DefaultBoolean()
  billNo      : simpleSchema.DefaultString('001')
  creator     : simpleSchema.DefaultCreator
  version     : { type: simpleSchema.Version }

  profiles:
    type: customerProfile
    optional: true

  transactions:
    type: customerTransaction
    optional: true

Schema.add 'customers', "Customer", class Customer
  @transform: (doc) ->
  @splitName: (fullText) ->
    if fullText.indexOf("(") > 0
      namePart        = fullText.substr(0, fullText.indexOf("(")).trim()
      descriptionPart = fullText.substr(fullText.indexOf("(")).replace("(", "").replace(")", "").trim()
      return { name: namePart, description: descriptionPart }
    else
      return { name: fullText }

  @insert: (name, callback) ->
    Schema.customers.insert({name: name}, callback)

  @nameIsExisted: (name, merchant) ->
    existedQuery = {name: name, merchant: merchant}
    Schema.customers.findOne(existedQuery)