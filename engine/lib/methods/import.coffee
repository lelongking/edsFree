Enums = Apps.Merchant.Enums
Meteor.methods
  importInventory: (importId)->
    user = Meteor.users.findOne(Meteor.userId())
    return {valid: false, error: 'user not found!'} if !user

    importQuery =
      _id        : importId
      creator    : user._id
      merchant   : user.profiles.merchant
      importType : Enums.getValue('ImportTypes', 'inventory')
    importFound = Schema.imports.findOne importQuery
    return {valid: false, error: 'import not found!'} if !importFound

    for detail in importFound.details
      detailIndex = 0; updateQuery = {$inc:{}}
      updateQuery.$inc["qualities.#{detailIndex}.availableQuality"]= detail.availableQuality
      updateQuery.$inc["qualities.#{detailIndex}.inStockQuality"]  = detail.inStockQuality
      updateQuery.$inc["qualities.#{detailIndex}.importQuality"]   = detail.importQuality
      Schema.products.update detail.product, updateQuery

    Schema.imports.update importId, $set:{importType: Enums.getValue('ImportTypes', 'inventorySuccess')}

  importConfirmed: (importId)->
    user = Meteor.users.findOne(Meteor.userId())
    return {valid: false, error: 'user not found!'} if !user

    importQuery =
      _id        : importId
      creator    : user._id
      merchant   : user.profiles.merchant
      importType : Enums.getValue('ImportTypes', 'checked')
    importFound = Schema.imports.findOne importQuery
    return {valid: false, error: 'import not found!'} if !importFound

    for detail in importFound.details
      detailIndex = 0; updateQuery = {$inc:{}}
      updateQuery.$inc["qualities.#{detailIndex}.availableQuality"]= detail.availableQuality
      updateQuery.$inc["qualities.#{detailIndex}.inStockQuality"]  = detail.inStockQuality
      updateQuery.$inc["qualities.#{detailIndex}.importQuality"]   = detail.importQuality
      Schema.products.update detail.product, updateQuery

    importUpdate = $set:
      importType         : Enums.getValue('ImportTypes', 'accounting')
      accounting         : user._id
      accountingConfirm  : true
      accountingConfirmAt: new Date()
    Schema.imports.update importId, importUpdate

  importAccountingConfirmed: (importId)->
    user = Meteor.users.findOne(Meteor.userId())
    return {valid: false, error: 'user not found!'} if !user

    importQuery =
      _id         : importId
      merchant    : user.profiles.merchant
      importType  : Enums.getValue('ImportTypes', 'accounting')
    importFound = Schema.imports.findOne importQuery
    return {valid: false, error: 'import not found!'} if !importFound

    Schema.imports.update importFound._id, $set:{importType: Enums.getValue('ImportTypes', 'success')}
