simpleSchema.inventories = new SimpleSchema
  merchant:
    type: String

  warehouse:
    type: String

  creator:
    type: String

  inventoryCode:
    type: String
    optional: true

  description:
    type: String

  resolved:
    type: Boolean
    defaultValue: false

  resolveDescription:
    type: String
    optional: true

  detail:
    type: Boolean
    defaultValue: false

# xac nhan nhan vien
  submit:
    type: Boolean
    defaultValue: false

# hoan thanh xac nhan quan ly
  success:
    type: Boolean
    defaultValue: false

  styles:
    type: String
    defaultValue: Helpers.RandomColor()
    optional: true

  version: { type: simpleSchema.Version }

Schema.add 'inventories' , "Inventory", class Inventory
  @findHistory: (starDate, toDate, warehouseId) ->
    @schema.find({$and: [
      {warehouse: warehouseId}
      {'version.createdAt': {$gt: new Date(starDate.getFullYear(), starDate.getMonth(), starDate.getDate())}}
      {'version.createdAt': {$lt: new Date(toDate.getFullYear(), toDate.getMonth(), toDate.getDate()+1)}}
    ]}, {sort: {'version.createdAt': -1}})
