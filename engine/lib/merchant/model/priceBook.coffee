simpleSchema.priceBooks = new SimpleSchema
  name          : {type: String   ,unique  : true, index: 1}
  description   : {type: String   ,optional: true}
  priceBookType : {type: Number   ,defaultValue: 1}

  merchant    : simpleSchema.DefaultMerchant
  isBase      : simpleSchema.DefaultBoolean(false)
  allowDelete : simpleSchema.DefaultBoolean()
  creator     : simpleSchema.DefaultCreator
  version     : {type: simpleSchema.Version}

  details                   : type: [Object], defaultValue: []
  'details.$._id'           : simpleSchema.UniqueId
  'details.$.product'       : type: String
  'details.$.productUnit'   : type: String
  'details.$.salePrice'     : {type: Number, min: 0}
  'details.$.importPrice'   : {type: Number, min: 0}

Schema.add 'priceBooks', "PriceBook", class PriceBook
  @transform: (doc) ->

  @insert: (name) -> Schema.priceBooks.insert {name: name} if name

  @nameIsExisted: (name, merchant = null) ->
    existedQuery = {name: name, merchant: merchant ? Meteor.user().profiles.merchant}
    Schema.priceBooks.findOne(existedQuery)

  @setSession: (priceBookId) ->
    Meteor.users.update(Meteor.userId(), {$set: {'sessions.currentPriceBook': priceBookId}})