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


  importAccountingConfirmed: (importId)->
    user = Meteor.users.findOne(Meteor.userId())
    return {valid: false, error: 'user not found!'} if !user

    importQuery =
      _id         : importId
      merchant    : user.profiles.merchant
      importType  : Enums.getValue('ImportTypes', 'staffConfirmed')
    importFound = Schema.imports.findOne importQuery
    return {valid: false, error: 'import not found!'} if !importFound

    providerFound = Schema.providers.findOne(importFound.provider)
    return {valid: false, error: 'provider not found!'} if !providerFound

    transactionInsert =
      transactionName : 'Phiếu Nhập'
#      transactionCode :
#      description     :
      transactionType  : Enums.getValue('TransactionTypes', 'provider')
      receivable       : true
      owner            : providerFound._id
      parent           : importFound._id
      beforeDebtBalance: providerFound.debtCash
      debtBalanceChange: importFound.finalPrice
      paidBalanceChange: importFound.depositCash
      latestDebtBalance: providerFound.debtCash + importFound.finalPrice - importFound.depositCash

    transactionInsert.dueDay = importFound.dueDay if importFound.dueDay

    if importFound.depositCash >= importFound.finalPrice # phiếu nhập đã thanh toán hết cho NCC
      transactionInsert.owedCash = 0
      transactionInsert.status   = Enums.getValue('TransactionStatuses', 'closed')
    else
      transactionInsert.owedCash = importFound.finalPrice - importFound.depositCash
      transactionInsert.status   = Enums.getValue('TransactionStatuses', 'tracking')

    if transactionId = Schema.transactions.insert(transactionInsert)
      providerUpdate =
        allowDelete : false
        paidCash    : providerFound.paidCash  + importFound.depositCash
        debtCash    : providerFound.debtCash  + importFound.finalPrice - importFound.depositCash
        totalCash   : providerFound.totalCash + importFound.finalPrice
      Schema.providers.update importFound.provider, $set: providerUpdate

      importUpdate = $set:
        importType         : Enums.getValue('ImportTypes', 'confirmedWaiting')
        accounting         : user._id
        accountingConfirm  : true
        accountingConfirmAt: new Date()
        transaction        : transactionId
      Schema.imports.update importFound._id, importUpdate


  importWarehouseConfirmed: (importId)->
    user = Meteor.users.findOne(Meteor.userId())
    return {valid: false, error: 'user not found!'} if !user

    importQuery =
      _id        : importId
      creator    : user._id
      merchant   : user.profiles.merchant
      importType : Enums.getValue('ImportTypes', 'confirmedWaiting')
    importFound = Schema.imports.findOne importQuery
    return {valid: false, error: 'import not found!'} if !importFound

    for detail in importFound.details
      detailIndex = 0; updateQuery = {$inc:{}}
      updateQuery.$inc["qualities.#{detailIndex}.availableQuality"]= detail.availableQuality
      updateQuery.$inc["qualities.#{detailIndex}.inStockQuality"]  = detail.inStockQuality
      updateQuery.$inc["qualities.#{detailIndex}.importQuality"]   = detail.importQuality
      Schema.products.update detail.product, updateQuery

    importUpdate = $set:
      importType : Enums.getValue('ImportTypes', 'success')

    Schema.providers.update importFound.provider, $set:{allowDelete: false}
    Schema.imports.update importFound._id, importUpdate
