Enums = Apps.Merchant.Enums
Meteor.methods
  providerToImport: (providerId)->
    try
      user = Meteor.users.findOne(Meteor.userId())
      throw {valid: false, error: 'user not found!'} if !user

      provider = Schema.providers.findOne({_id: providerId, merchant: user.profile.merchant})
      throw {valid: false, error: 'provider not found!'} if !provider

      importFound = Schema.imports.findOne({
        creator   : user._id
        provider  : provider._id
        merchant  : user.profile.merchant
        importType: Enums.getValue('ImportTypes', 'initialize')
      }, {sort: {'version.createdAt': -1}})

      if importFound
        Import.setSession(importFound._id)
      else
        Import.setSession(importId) if importId = Import.insert(provider._id, provider.name)

    catch error
      throw new Meteor.Error('providerToImport', error)


  importInventory: (importId)->
    user = Meteor.users.findOne(Meteor.userId())
    return {valid: false, error: 'user not found!'} if !user

    importQuery =
      _id        : importId
      creator    : user._id
      merchant   : user.profile.merchant
      importType : Enums.getValue('ImportTypes', 'inventory')
    importFound = Schema.imports.findOne importQuery
    return {valid: false, error: 'import not found!'} if !importFound

    for detail in importFound.details
      detailIndex = 0; updateQuery = {$inc:{}}
      product = Schema.products.findOne(detail.product)
      for unit, index in product.units
        if unit._id is detail.productUnit
          updateQuery.$inc["units.#{index}.quality.availableQuality"] = detail.basicQuality
          updateQuery.$inc["units.#{index}.quality.inStockQuality"]   = detail.basicQuality
          updateQuery.$inc["units.#{index}.quality.importQuality"]    = detail.basicQuality
          break

      updateQuery.$inc["qualities.#{detailIndex}.availableQuality"]= detail.basicQuality
      updateQuery.$inc["qualities.#{detailIndex}.inStockQuality"]  = detail.basicQuality
      updateQuery.$inc["qualities.#{detailIndex}.importQuality"]   = detail.basicQuality
      console.log updateQuery
      Schema.products.update detail.product, updateQuery

    Schema.imports.update importId, $set:{importType: Enums.getValue('ImportTypes', 'inventorySuccess')}


  importAccountingConfirmed: (importId)->
    user = Meteor.users.findOne(Meteor.userId())
    return {valid: false, error: 'user not found!'} if !user

    importQuery =
      _id         : importId
      merchant    : user.profile.merchant
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
      beforeDebtBalance: providerFound.totalCash
      debtBalanceChange: importFound.finalPrice
      paidBalanceChange: importFound.depositCash
      latestDebtBalance: providerFound.totalCash + importFound.finalPrice - importFound.depositCash

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
      merchant   : user.profile.merchant
      importType : Enums.getValue('ImportTypes', 'confirmedWaiting')
    importFound = Schema.imports.findOne importQuery
    return {valid: false, error: 'import not found!'} if !importFound

    providerFound = Schema.providers.findOne(importFound.provider)
    return {valid: false, error: 'provider not found!'} if !providerFound

    merchantFound = Schema.merchants.findOne(user.profile?.merchant)
    return {valid: false, error: 'merchant not found!'} if !merchantFound

    importUpdate = $set:
      importType : Enums.getValue('ImportTypes', 'success')
      successDate: new Date()
      importCode : "#{Helpers.orderCodeCreate(providerFound.billNo)}/#{Helpers.orderCodeCreate(merchantFound.importBill)}"

    for detail, detailIndex in importFound.details
      if product = Schema.products.findOne(detail.product)
        productDetailIndex = 0; updateQuery = {$inc:{}}
        for unit, index in product.units
          if unit._id is detail.productUnit
            updateQuery.$inc["units.#{index}.quality.availableQuality"] = detail.basicQuality
            updateQuery.$inc["units.#{index}.quality.inStockQuality"]   = detail.basicQuality
            updateQuery.$inc["units.#{index}.quality.importQuality"]    = detail.basicQuality
            break

        updateQuery.$inc["qualities.#{productDetailIndex}.availableQuality"] = detail.basicQuality
        updateQuery.$inc["qualities.#{productDetailIndex}.inStockQuality"]   = detail.basicQuality
        updateQuery.$inc["qualities.#{productDetailIndex}.importQuality"]    = detail.basicQuality
        updateQuery.$set = {lastExpire: detail.expire} if detail.expire
        Schema.products.update detail.product, updateQuery

      #Todo: tim phieu ban chua tru kho, roi tru kho tai day, cap nhat ghi chu
      orderFounds = Schema.orders.find({
        merchant                : Merchant.getId()
        'detail.$.productUnit'  : detail.productUnit
        'detail.$.importIsValid': {$ne: true}
      }).fetch()

      if orderFounds.length > 0
      else
        importUpdate.$set["details.#{detailIndex}.note"] = 'Nhập kho mới'

    Schema.imports.update importFound._id, importUpdate
    Schema.merchants.update(merchantFound._id, $inc:{importBill: 1})
    Schema.providers.update importFound.provider, {$set:{allowDelete: false}, $inc: {billNo: 1}}
