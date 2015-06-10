simpleSchema.deliveries = new SimpleSchema
  merchant:
    type: String
    optional: true

  warehouse:
    type: String

  creator:
    type: String

  buyer:
    type: String

  sale:
    type: String
    optional: true
#------------------------
  deliveryAddress:
    type: String

  contactName:
    type: String
    optional: true

  contactPhone:
    type: String

  deliveryDate:
    type: Date
    optional: true

  comment:
    type: String
    optional: true

  transportationFee:
    type: Number
    optional: true

  status:
    type: Number

  shipper:
    type: String
    optional: true

  exporter:
    type: String
    optional: true

  importer:
    type: String
    optional: true

  cashier:
    type: String
    optional: true

  styles:
    type: String
    defaultValue: Helpers.RandomColor()
    optional: true

  version: { type: simpleSchema.Version }


Schema.add 'deliveries', "Delivery", class Delivery
  @newBySale: (order, sale)->
    option =
      merchant        : sale.merchant
      warehouse       : sale.warehouse
      creator         : sale.creator
      sale            : sale._id
      buyer           : sale.buyer
      contactName     : order.contactName
      contactPhone    : order.contactPhone
      deliveryAddress : order.deliveryAddress
      comment         : order.comment
      status          : 0

    option.deliveryDate = order.deliveryDate if order.deliveryDate
    option


  @insertBySale: (order, sale)-> @schema.insert Delivery.newBySale(order, sale)



