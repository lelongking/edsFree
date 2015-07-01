providerProfile = new SimpleSchema
  phone          : simpleSchema.OptionalString
  billNo         : simpleSchema.DefaultString('001')
  representative : simpleSchema.OptionalString
  manufacturer   : simpleSchema.OptionalString

providerTransaction = new SimpleSchema
  importPaid     : simpleSchema.DefaultNumber()
  importDebt     : simpleSchema.DefaultNumber()
  importTotalCash: simpleSchema.DefaultNumber()


simpleSchema.providers = new SimpleSchema
  name        : simpleSchema.StringUniqueIndex
  nameSearch  : simpleSchema.searchSource('name')
  description : simpleSchema.OptionalString

  merchant    : simpleSchema.DefaultMerchant
  avatar      : simpleSchema.OptionalString
  allowDelete : simpleSchema.DefaultBoolean()
  creator     : simpleSchema.DefaultCreator
  version     : { type: simpleSchema.Version }

  profiles:
    type: providerProfile
    optional: true

  transactions:
    type: providerTransaction
    optional: true

Schema.add 'providers', "Provider", class Provider
  @transform: (doc) ->
    doc.remove = -> Schema.providers.remove(@_id, callback) if @allowDelete

  @insert: (name, description, callback) ->
    Schema.providers.insert({name: name, description: description}, callback)

  @splitName: (fullText) ->
    if fullText.indexOf("(") > 0
      namePart        = fullText.substr(0, fullText.indexOf("(")).trim()
      descriptionPart = fullText.substr(fullText.indexOf("(")).replace("(", "").replace(")", "").trim()
      return { name: namePart, description: descriptionPart }
    else
      return { name: fullText }

  @nameIsExisted: (name, merchant) ->
    existedQuery = {name: name, merchant: merchant}
    Schema.providers.findOne(existedQuery)