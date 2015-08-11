Enums = Apps.Merchant.Enums
Meteor.methods
  createTransaction: (ownerId, money, name = null, description = null, transactionType = Enums.getValue('TransactionTypes', 'customer'), receivable = undefined)->
    console.log ownerId, money, name, description, transactionType, receivable


    if transactionType is Enums.getValue('TransactionTypes', 'provider')
      owner = Schema.providers.findOne(ownerId)
    else if transactionType is Enums.getValue('TransactionTypes', 'customer')
      owner = Schema.customers.findOne(ownerId)

    if owner
      transaction = Schema.transactions.findOne({owner: owner._id}, {sort: {'version.createdAt': -1}})

      ownerUpdate = $set: {allowDelete : false}, $inc:{}
      ownerUpdate.$inc.totalCash = if receivable then money else -money
      if transaction # tao phieu tra tien, no cu. ko co tao phieu ban voi tra hang
        ownerUpdate.$inc.paidCash  = if receivable then 0 else money
        ownerUpdate.$inc.loanCash  = if receivable then money else 0
      else #Nhap ton dau ky
        ownerUpdate.$inc.beginCash = if receivable then money else -money

      transactionInsert =
  #      transactionCode :
        transactionType   : transactionType
        owner             : owner._id
        receivable        : receivable
        beforeDebtBalance : owner.totalCash
        owedCash          : money
        status            : Enums.getValue('TransactionStatuses', if receivable then 'tracking' else 'closed')

      transactionInsert.transactionName = name if name
      transactionInsert.description = description if description
      transactionInsert.parent = transaction.parent if transaction?.parent
      transactionInsert.isBeginCash = if transaction then false else true

      if transactionType is Enums.getValue('TransactionTypes', 'provider')
        transactionInsert.transactionName   = if receivable then 'Phiếu Thu' else 'Phiếu Chi'
        transactionInsert.debtBalanceChange = if receivable then money else 0
        transactionInsert.paidBalanceChange = if receivable then 0 else money

      else if transactionType is Enums.getValue('TransactionTypes', 'customer')
        transactionInsert.transactionName   = if receivable then 'Phiếu Chi' else 'Phiếu Thu'
        transactionInsert.debtBalanceChange = if receivable then money else 0
        transactionInsert.paidBalanceChange = if receivable then 0 else money

      latestDebtBalance = transactionInsert.beforeDebtBalance + ownerUpdate.$inc.totalCash
      transactionInsert.latestDebtBalance = latestDebtBalance

      if Schema.transactions.insert(transactionInsert)
        if transactionType is Enums.getValue('TransactionTypes', 'provider')
          Schema.providers.update owner._id, ownerUpdate
        else if transactionType is Enums.getValue('TransactionTypes', 'customer')
          Schema.customers.update owner._id, ownerUpdate
          Schema.customerGroups.update owner.group, $inc:{totalCash: ownerUpdate.$inc.totalCash} if owner.group


  # chi xoa transaction no dau ky, voi phieu tra tien, no cu, ko xoa dc phieu ban hang va tra hang
  deleteTransaction: (transactionId) ->
    if transaction = Schema.transactions.findOne transactionId
      if transaction.transactionType is Enums.getValue('TransactionTypes', 'provider')
        parent = Schema.imports.findOne(transaction.parent)
      else if transaction.transactionType is Enums.getValue('TransactionTypes', 'customer')
        parent = Schema.orders.findOne(transaction.parent)
      else
        parent = Schema.returns.findOne(transaction.parent)

      if !parent or parent.transaction isnt transaction._id
        latestDebtBalance = 0; beforeDebtBalance = transaction.beforeDebtBalance
        query = {owner: transaction.owner, 'version.createdAt': {$gt: transaction.version.createdAt}}

        Schema.transactions.find(query, {sort: {'version.createdAt': 1}}).forEach(
          (item) ->
            if item.transactionType is Enums.getValue('TransactionTypes', 'provider')
              latestDebtBalance = beforeDebtBalance + item.debtBalanceChange - item.paidBalanceChange
            else if item.transactionType is Enums.getValue('TransactionTypes', 'customer')
              latestDebtBalance = beforeDebtBalance + item.debtBalanceChange - item.paidBalanceChange

            Schema.transactions.update item._id, $set:{beforeDebtBalance: beforeDebtBalance, latestDebtBalance: latestDebtBalance}
            beforeDebtBalance = latestDebtBalance
        )

        if Schema.transactions.remove transaction._id
          if transaction.transactionType is Enums.getValue('TransactionTypes', 'provider')
            if transaction.isBeginCash #no ton day ky
              updateOwner =
                beginCash  : transaction.paidBalanceChange - transaction.debtBalanceChange
                totalCash  : transaction.paidBalanceChange - transaction.debtBalanceChange
            else
              updateOwner =
                paidCash   : -transaction.paidBalanceChange
                loanCash   : -transaction.debtBalanceChange
                totalCash  : transaction.paidBalanceChange - transaction.debtBalanceChange
            Schema.providers.update transaction.owner, $inc: updateOwner

          else if transaction.transactionType is Enums.getValue('TransactionTypes', 'customer')
            if transaction.isBeginCash #no ton day ky
              updateOwner =
                beginCash  : transaction.paidBalanceChange - transaction.debtBalanceChange
                totalCash  : transaction.paidBalanceChange - transaction.debtBalanceChange
            else
              updateOwner =
                paidCash   : -transaction.paidBalanceChange
                loanCash   : -transaction.debtBalanceChange
                totalCash  : transaction.paidBalanceChange - transaction.debtBalanceChange

            Schema.customers.update transaction.owner, $inc: updateOwner
            if customer = Schema.customers.findOne(transaction.owner)
              Schema.customerGroups.update customer.group, $inc:{totalCash: updateOwner.totalCash} if customer.group