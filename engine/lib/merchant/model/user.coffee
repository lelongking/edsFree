cloneName =
  type: String
  autoValue: ->
    return if !@isInsert
    return @field('username').value

userProfile = new SimpleSchema
  name:
    type: String

  gender:
    type: Boolean
    optional: true

  dateOfBirth:
    type: Date
    optional: true

  address:
    type: String
    optional: true

  image:
    type: String
    optional: true

  description:
    type: String
    optional: true

  merchant:
    type: String
    optional: true

userSession = new SimpleSchema
  currentProduct        : simpleSchema.OptionalString
  currentProductGroup   : simpleSchema.OptionalString
  currentCustomer       : simpleSchema.OptionalString
  currentCustomerGroup  : simpleSchema.OptionalString
  currentProvider       : simpleSchema.OptionalString
  currentOrder          : simpleSchema.OptionalString
  currentPriceBook      : simpleSchema.OptionalString
  currentImport         : simpleSchema.OptionalString
  currentCustomerReturn : simpleSchema.OptionalString
  currentProviderReturn : simpleSchema.OptionalString

  customerSelected      : type: Object, blackbox: true, optional: true
  productSelected       : type: Object, blackbox: true, optional: true
  productUnitSelected   : type: Object, blackbox: true, optional: true

Meteor.users.attachSchema new SimpleSchema
  username:
    type: String
    regEx: /^[a-z0-9A-Z_]{3,15}$/
    optional: true

  emails:
    type: [Object]
    optional: true

  "emails.$.address":
    type: String
    regEx: SimpleSchema.RegEx.Email

  "emails.$.verified":
    type: Boolean

  services:
    type: Object
    optional: true
    blackbox: true

  status:
    type: Object
    optional: true
    blackbox: true

  profiles:
    type: userProfile
    optional: true
  "profiles.name": cloneName

  sessions:
    type: userSession
    defaultValue: {}

  creator  : simpleSchema.DefaultCreator
  createdAt: type: Date