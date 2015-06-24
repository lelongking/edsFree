simpleSchema.returns = new SimpleSchema
  returnName  : simpleSchema.DefaultString('Trả hàng')
  returnType  : simpleSchema.DefaultNumber()
  status      : simpleSchema.DefaultNumber()
  owner       : simpleSchema.OptionalString

  merchant    : simpleSchema.DefaultMerchant
  allowDelete : simpleSchema.DefaultBoolean()
  creator     : simpleSchema.DefaultCreator
  version: { type: simpleSchema.Version }

  profiles                    : type: Object , optional: true
  'profiles.description'      : simpleSchema.OptionalString
  'profiles.returnCode'       : simpleSchema.OptionalString
  'profiles.returnMethods'    : simpleSchema.DefaultNumber()

  'profiles.discountCash'     : simpleSchema.DefaultNumber()
  'profiles.depositCash'      : simpleSchema.DefaultNumber()
  'profiles.totalPrice'       : simpleSchema.DefaultNumber()
  'profiles.finalPrice'       : simpleSchema.DefaultNumber()

  details                   : type: [Object], defaultValue: []
  'details.$._id'           : simpleSchema.UniqueId
  'details.$.product'       : type: String
  'details.$.productUnit'   : type: String
  'details.$.quality'       : {type: Number, min: 0}
  'details.$.price'         : {type: Number, min: 0}
  'details.$.discountCash'  : simpleSchema.DefaultNumber()
  'details.$.basicQuality'  : {type: Number, min: 0}
  'details.$.conversion'    : {type: Number, min: 1}

  'details.$.productDetails'               : type: [Object], optional: true
  'details.$.productDetails.$._id'         : type: String
  'details.$.productDetails.$.quality'     : type: Number, optional: true

Schema.add 'returns', "Return", class Return
  @transform: (doc) ->
    doc.remove = -> Schema.returns.remove @_id if @allowDelete

  @insert: (returnType = 'customer')->
    Schema.returns.insert {}

  @findNotSubmitOf: (returnType = 'customer')->
    if returnType is 'customer'
      Schema.returns.find({returnType: 0})
    else if returnType is 'provider'
      Schema.returns.find({returnType: 1})

  @setReturnSession: (returnId, returnType = 'customer')->
    if returnType is 'customer'
      updateSession = $set: {'sessions.currentCustomerReturn': returnId}
    else if returnType is 'provider'
      updateSession = $set: {'sessions.currentProviderReturn': returnId}

    Meteor.users.update Meteor.userId(), updateSession

