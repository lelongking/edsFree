Enums = Apps.Merchant.Enums
Meteor.methods
  createTransaction: (ownerId, money, name = null, description = null, transactionType = Enums.getValue('TransactionTypes', 'customer'), receivable = false)->
    if transactionType is Enums.getValue('TransactionTypes', 'provider')
      owner = Schema.providers.findOne(ownerId)
    else if transactionType is Enums.getValue('TransactionTypes', 'customer')
      owner = Schema.customers.findOne(ownerId)

    if owner
      transaction = Schema.transactions.findOne({owner: owner._id}, {sort: {'version.createdAt': -1}})
      ownerUpdate = $set: {allowDelete : false}, $inc:{}
      transactionInsert =
  #      transactionCode :
        transactionType  : transactionType
        owner            : owner._id
        receivable       : receivable
        beforeDebtBalance: owner.debtCash

      if transactionType is Enums.getValue('TransactionTypes', 'provider')
        transactionInsert.transactionName = if receivable then 'Phiếu Thu' else 'Phiếu Chi'
      else if transactionType is Enums.getValue('TransactionTypes', 'customer')
        transactionInsert.transactionName = if receivable then 'Phiếu Chi' else 'Phiếu Thu'

      transactionInsert.transactionName = name if name
      transactionInsert.description = description if description
      transactionInsert.parent = transaction.parent if transaction?.parent



      if transaction
        if receivable #no cu
          ownerUpdate.$inc.beginCash = 0
          ownerUpdate.$inc.debtCash  = 0
          ownerUpdate.$inc.paidCash  = 0
          ownerUpdate.$inc.returnCash= 0
          ownerUpdate.$inc.loanCash  = money
          ownerUpdate.$inc.totalCash = money

          transactionInsert.owedCash          = money
          transactionInsert.status            = Enums.getValue('TransactionStatuses', 'tracking')
          transactionInsert.debtBalanceChange = money
          transactionInsert.paidBalanceChange = 0
        else #tra no
          ownerUpdate.$inc.beginCash = 0
          ownerUpdate.$inc.paidCash  = money
          ownerUpdate.$inc.returnCash= 0
          ownerUpdate.$inc.loanCash  = 0
          ownerUpdate.$inc.debtCash  = 0
          ownerUpdate.$inc.totalCash = -money

          transactionInsert.owedCash          = -money
          transactionInsert.status            = Enums.getValue('TransactionStatuses', 'closed')
          transactionInsert.debtBalanceChange = 0
          transactionInsert.paidBalanceChange = money

      else #Nhap ton dau ky
        if receivable #no cu
          ownerUpdate.$inc.beginCash = money
          ownerUpdate.$inc.debtCash  = 0
          ownerUpdate.$inc.paidCash  = 0
          ownerUpdate.$inc.returnCash= 0
          ownerUpdate.$inc.loanCash  = 0
          ownerUpdate.$inc.totalCash = money

          transactionInsert.owedCash          = money
          transactionInsert.status            = Enums.getValue('TransactionStatuses', 'tracking')
          transactionInsert.debtBalanceChange = money
          transactionInsert.paidBalanceChange = 0
        else #tra no
        ownerUpdate.$inc.beginCash = -money
        ownerUpdate.$inc.paidCash  = 0
        ownerUpdate.$inc.returnCash= 0
        ownerUpdate.$inc.loanCash  = 0
        ownerUpdate.$inc.totalCash = 0
        ownerUpdate.$inc.debtCash  = -money

        transactionInsert.owedCash          = -money
        transactionInsert.status            = Enums.getValue('TransactionStatuses', 'closed')
        transactionInsert.debtBalanceChange = 0
        transactionInsert.paidBalanceChange = money

      #transaction dang tru sai, sai so
      latestDebtBalance = transactionInsert.beforeDebtBalance + transactionInsert.debtBalanceChange - transactionInsert.paidBalanceChange
      transactionInsert.latestDebtBalance = latestDebtBalance

      if Schema.transactions.insert(transactionInsert)
        if transactionType is Enums.getValue('TransactionTypes', 'provider')
          Schema.providers. update owner._id, ownerUpdate
        else if transactionType is Enums.getValue('TransactionTypes', 'customer')
          Schema.customers.update owner._id, ownerUpdate
          totalCash = (ownerUpdate.$inc.money + ownerUpdate.$inc.loanCash)
          Schema.customerGroups.update owner.group, $inc:{totalCash: totalCash} if owner.group



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
            if customer = Schema.customers.findOne(transaction.owner)
              Schema.customerGroups.update customer.group, $inc:{totalCash: (transaction.paidBalanceChange - transaction.debtBalanceChange)} if customer.group