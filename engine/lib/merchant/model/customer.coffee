customerProfile = new SimpleSchema
  phone       : simpleSchema.OptionalString
  address     : simpleSchema.OptionalString
  gender      : simpleSchema.DefaultBoolean()
  billNo      : simpleSchema.DefaultString('000')
  areas       : simpleSchema.OptionalStringArray

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
  group       : simpleSchema.OptionalString

  merchant    : simpleSchema.DefaultMerchant
  avatar      : simpleSchema.OptionalString
  allowDelete : simpleSchema.DefaultBoolean()
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