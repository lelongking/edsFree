randomBarcode = (prefix="0", length=10)->
  prefix += Math.floor(Math.random() * 10) for i in [0...length]
  prefix

simpleSchema.Version = new SimpleSchema
  createdAt:
    type: Date
    autoValue: ->
      if @isInsert
        return new Date
      else if @isUpsert
        return { $setOnInsert: new Date }
      return

  updateAt:
    type: Date
    autoValue: ->
      return new Date() if @isUpdate
      return
    denyInsert: true
    optional: true

simpleSchema.Location = new SimpleSchema
  address:
    type: [String]
    optional: true

  areas:
    type: [String]
    optional: true

simpleSchema.Detail = new SimpleSchema
  _id:
    type: String

  detailId:
    type: String

  product:
    type: String

  productUnit:
    type: String

  owner:
    type: String

  note:
    type    : String
    optional: true

  quality:
    type: Number

  basicQuantity:
    type: Number

  conversion:
    type: Number

  price:
    type: Number

  createdAt:
    type: Date


simpleSchema.StringUniqueIndex   = { type: String, unique: true, index: 1 }
#----------------- Optional Value ------------------------>
simpleSchema.OptionalString      = { type: String  , optional: true }
simpleSchema.OptionalString      = { type: String  , optional: true }
simpleSchema.OptionalStringArray = { type: [String], optional: true }
simpleSchema.OptionalObject      = { type: Object  , optional: true }
simpleSchema.OptionalObjectArray = { type: [Object], optional: true }
simpleSchema.OptionalNumber      = { type: Number  , optional: true }
simpleSchema.OptionalNumberArray = { type: [Number], optional: true }

#----------------- Default Value ------------------------>
simpleSchema.searchSource = (field) ->
  type: String
  autoValue: ->
    return Helpers.Searchify(@field(field).value) if @field(field).isSet

simpleSchema.DefaultString = (value = '') ->
  type: String
  autoValue: ->
    if @isInsert
      return value
    else if @isUpsert
      return { $setOnInsert: value }
    else if @isUpdate and @operator is "$push"
      return value
    return


simpleSchema.DefaultBoolean = (value = true) ->
  type: Boolean
  autoValue: ->
    if @isInsert
      return value
    else if @isUpsert
      return { $setOnInsert: value }
    else if @isUpdate and @operator is "$push"
      return value
    return


simpleSchema.DefaultNumber = (number = 0)->
  type: Number
  autoValue: ->
    if @isInsert
      return number
    else if @isUpsert
      return { $setOnInsert: number }
    else if @isUpdate and @operator is "$push"
      return number
    return


#----------------- Auto Value ------------------------>
simpleSchema.UniqueId =
  type: String
  autoValue: ->
    return Random.id() unless @isSet
    return

simpleSchema.Barcode =
  type: String
  autoValue: ->
    return randomBarcode() unless @isSet
    return

simpleSchema.DefaultMerchant =
  type: String
  autoValue: ->
    if @isInsert and not @isSet
      Meteor.user().profile.merchant

simpleSchema.DefaultCreator =
  type: String
  autoValue: -> Meteor.userId() if @isInsert and not @isSet

simpleSchema.DefaultCreatedAt =
  type: Date
  autoValue: ->
    return new Date unless @isSet
    return

simpleSchema.BooleanNotUpdate = (value = true) ->
  type: Boolean
  autoValue: ->
    if @isInsert
      return value
    else if @isUpsert
      return { $setOnInsert: value }
    return