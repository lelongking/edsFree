Enums = Apps.Merchant.Enums
Meteor.methods
  createTransaction: (ownerId, debtCash, name = null, description = null, transactionType = Enums.getValue('TransactionTypes', 'customer'), receivable = false)->
    if transactionType is Enums.getValue('TransactionTypes', 'provider')
      owner = Schema.providers.findOne(ownerId)
    else if transactionType is Enums.getValue('TransactionTypes', 'customer')
      owner = Schema.customers.findOne(ownerId)

    transaction = Schema.transactions.findOne({owner: owner._id}, {sort: {'version.createdAt': 1}})

    if owner
      ownerUpdate = $set: {allowDelete : false}, $inc:{}
      transactionInsert =
  #      transactionCode :
        transactionType  : transactionType
        receivable       : receivable
        owner            : owner._id
        beforeDebtBalance: owner.debtCash + owner.loanCash

      transactionInsert.parent = transaction.parent if transaction?.parent
      transactionInsert.description = description if description

      if name
        transactionInsert.transactionName = name
      else
        if transactionType is Enums.getValue('TransactionTypes', 'provider')
          transactionInsert.transactionName = if receivable then 'Phiếu Thu' else 'Phiếu Chi'
        else if transactionType is Enums.getValue('TransactionTypes', 'customer')
          transactionInsert.transactionName = if receivable then 'Phiếu Chi' else 'Phiếu Thu'

      paidCash = 0 #paidCash -> tien nhan, debtCash -> tien tra.
      if receivable
        ownerUpdate.$inc.paidCash  = paidCash
        ownerUpdate.$inc.debtCash  = -paidCash
        ownerUpdate.$inc.loanCash  = debtCash
        ownerUpdate.$inc.totalCash = debtCash

        transactionInsert.owedCash          = debtCash - paidCash
        transactionInsert.status            = Enums.getValue('TransactionStatuses', 'tracking')
        transactionInsert.debtBalanceChange = debtCash
        transactionInsert.paidBalanceChange = paidCash
      else
        ownerUpdate.$inc.paidCash  = debtCash
        ownerUpdate.$inc.debtCash  = -debtCash
        ownerUpdate.$inc.loanCash  = paidCash
        ownerUpdate.$inc.totalCash = paidCash

        transactionInsert.owedCash          = 0
        transactionInsert.status            = Enums.getValue('TransactionStatuses', 'closed')
        transactionInsert.debtBalanceChange = paidCash
        transactionInsert.paidBalanceChange = debtCash

      latestDebtBalance = transactionInsert.beforeDebtBalance + transactionInsert.debtBalanceChange - transactionInsert.paidBalanceChange
      transactionInsert.latestDebtBalance = latestDebtBalance

      if Schema.transactions.insert(transactionInsert)
        if transactionType is Enums.getValue('TransactionTypes', 'provider')
          Schema.providers. update owner._id, ownerUpdate
        else if transactionType is Enums.getValue('TransactionTypes', 'customer')
          Schema.customers.update owner._id, ownerUpdate

  deleteTransaction: (transactionId) ->
    if transaction = Schema.transactions.findOne transactionId
      if transaction.transactionType is Enums.getValue('TransactionTypes', 'provider')
        parent = Schema.imports.findOne(transaction.parent)
      else if transaction.transactionType is Enums.getValue('TransactionTypes', 'customer')
        parent = Schema.orders.findOne(transaction.parent)

      if !parent or parent.transaction isnt transaction._id
        latestDebtBalance = 0; beforeDebtBalance = transaction.beforeDebtBalance
        query = {owner: transaction.owner, 'version.createdAt': {$gt: transaction.version.createdAt}}

        Schema.transactions.find(query, {sort: {'version.createdAt': 1}}).forEach(
          (item) ->
            latestDebtBalance = beforeDebtBalance + item.debtBalanceChange - item.paidBalanceChange
            Schema.transactions.update item._id, $set:{beforeDebtBalance: beforeDebtBalance, latestDebtBalance: latestDebtBalance}
            beforeDebtBalance = latestDebtBalance
        )

        if Schema.transactions.remove transaction._id
          updateOwner =
            paidCash  : -transaction.paidBalanceChange
            debtCash  : +transaction.paidBalanceChange
            loanCash  : -transaction.debtBalanceChange
            totalCash : -transaction.debtBalanceChange

          if transaction.transactionType is Enums.getValue('TransactionTypes', 'provider')
            Schema.providers.update transaction.owner, $inc: updateOwner
          else if transaction.transactionType is Enums.getValue('TransactionTypes', 'customer')
            Schema.customers.update transaction.owner, $inc: updateOwner