Enums = Apps.Merchant.Enums
Meteor.methods
  reCalculateProviderDebt: (providerId)->
    transactionQuery =
#      transactionType: Enums.getValue('TransactionTypes', 'provider')
      owner          : providerId

    updateProvider = { paidCash: 0, debtCash: 0, loanCash: 0, totalCash: 0 }
    Schema.transactions.find(transactionQuery).forEach(
      (transaction) ->
        if transaction.receivable
          updateProvider.totalCash += transaction.debtBalanceChange
          updateProvider.paidCash  += transaction.paidBalanceChange
          updateProvider.debtCash  += transaction.debtBalanceChange - transaction.paidBalanceChange
        else
#          updateProvider.totalCash += transaction.debtBalanceChange
#          updateProvider.paidCash  += transaction.paidBalanceChange
#          updateProvider.debtCash  += transaction.debtBalanceChange
    )
    console.log updateProvider
    Schema.providers.update providerId, $set: updateProvider