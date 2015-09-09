simpleSchema.inventoryDetails = new SimpleSchema
  merchant:
    type: String

  warehouse:
    type: String

  creator:
    type: String

  inventory:
    type: String

  product:
    type: String

  productDetail:
    type: String

#so luong trong kho
  lockOriginalQuantity:
    type: Number
    defaultValue: 0

#so luong trong kho
  originalQuantity:
    type: Number
    defaultValue: 0

#so luong kiem tra
  realQuantity:
    type: Number
    defaultValue: 0

#so luong ban khi kiem kho
  saleQuantity:
    type: Number
    defaultValue: 0

#so luong mat tiem lai dc
  lostQuantity:
    type: Number
    defaultValue: 0

  resolved:
    type: Boolean
    defaultValue: false

  lock:
    type: Boolean
    defaultValue: false

  lockDate:
    type: Date
    optional: true

  submit:
    type: Boolean
    defaultValue: false

  submitDate:
    type: Date
    optional: true

  success:
    type: Boolean
    defaultValue: false

  successDate:
    type: Date
    optional: true

  status:
    type: Boolean
    defaultValue: false

  version: { type: simpleSchema.Version }

