simpleSchema.notifications = new SimpleSchema
  message:
    type: String

  notificationType:
    type: String

  seen:
    type: Boolean
    defaultValue: false

  reads:
    type: [String]
    optional: true

  isRequest:
    type: Boolean
    defaultValue: false

  confirmed:
    type: Boolean
    defaultValue: false


  class:
    type: String
    optional: true

  group:
    type: String
    optional: true

  characteristic:
    type: String
    optional: true


  merchant:
    type: String
    optional: true

  sender:
    type: String
    optional: true

  receiver:
    type: String
    optional: true

  product:
    type: String
    optional: true

  customer:
    type: String
    optional: true

  provider:
    type: String
    optional: true

  version: { type: simpleSchema.Version }