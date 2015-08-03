simpleSchema.providers = new SimpleSchema
  name        : simpleSchema.StringUniqueIndex
  nameSearch  : simpleSchema.searchSource('name')
  description : simpleSchema.OptionalString

  phone          : simpleSchema.OptionalString
  address        : simpleSchema.OptionalString
  billNo         : type: Number, defaultValue: 0
  representative : simpleSchema.OptionalString
  manufacturer   : simpleSchema.OptionalString

  paidCash  : simpleSchema.DefaultNumber()
  debtCash  : simpleSchema.DefaultNumber()
  loanCash  : simpleSchema.DefaultNumber()
  totalCash : simpleSchema.DefaultNumber()

  merchant    : simpleSchema.DefaultMerchant
  avatar      : simpleSchema.OptionalString
  allowDelete : simpleSchema.DefaultBoolean()
  creator     : simpleSchema.DefaultCreator
  version     : { type: simpleSchema.Version }

Schema.add 'providers', "Provider", class Provider
  @transform: (doc) ->
    doc.remove = -> Schema.providers.remove(@_id) if @allowDelete

  @insert: (name, description, callback) ->
    Schema.providers.insert({name: name, description: description}, callback)

  @splitName: (fullText) ->
    if fullText.indexOf("(") > 0
      namePart        = fullText.substr(0, fullText.indexOf("(")).trim()
      descriptionPart = fullText.substr(fullText.indexOf("(")).replace("(", "").replace(")", "").trim()

      return { name: Helpers.ConvertNameUpperCase(namePart), description: descriptionPart }
    else
      return { name: Helpers.ConvertNameUpperCase(fullText) }

  @nameIsExisted: (name, merchant) ->
    existedQuery = {name: name, merchant: merchant}
    Schema.providers.findOne(existedQuery)

  @selectProvider: (providerId) ->
    if userId = Meteor.userId()
      Session.set "providerManagementShowEditCommand"
#      Meteor.subscribe('providerManagementCurrentProviderData', @providerId)
      Meteor.users.update(userId, {$set: {'sessions.currentProvider': providerId}})
