Enums = Apps.Merchant.Enums
logics.transaction = {}
Apps.Merchant.transactionInit = []
Apps.Merchant.transactionReactive = []

Apps.Merchant.transactionReactive.push (scope) ->
  transaction = Session.get('transactionDetail')
  if transaction?.owner
    if transaction.transactionType is Enums.getValue('TransactionTypes', 'provider')
      owner = Schema.providers.findOne(transaction.owner)
    else if transaction.transactionType is Enums.getValue('TransactionTypes', 'customer')
      owner = Schema.customers.findOne(transaction.owner)
    Session.set('transactionOwner', owner)

Apps.Merchant.transactionInit.push (scope) ->