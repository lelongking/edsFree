cloneName =
  type: String
  autoValue: ->
    return if !@isInsert
    return @field('username').value

userProfile = new SimpleSchema
  name:
    type: String

  gender:
    type: String
    allowedValues: ['Male', 'Female']
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
  currentProduct : simpleSchema.OptionalString
  currentCustomer: simpleSchema.OptionalString
  currentProvider: simpleSchema.OptionalString



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

  profile:
    type: userProfile
    optional: true
  "profile.name": cloneName

  sessions:
    type: userSession
    defaultValue: {}

  creator  : simpleSchema.DefaultCreator
  createdAt: type: Date