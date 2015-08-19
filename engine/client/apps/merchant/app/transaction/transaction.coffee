Enums = Apps.Merchant.Enums
scope = logics.transaction

findTransactionReceivable = (receivable) -> _.findWhere(Enums.TransactionReceivable, {_id: receivable})
findTransactionType       = (transactionType) -> _.findWhere(Enums.TransactionTypes, {_id: transactionType})
formatDefaultSearch       = (item) -> "#{item.display}" if item
formatReceivableSearch    = (item) ->
  transaction = Session.get('transactionDetail')
  if transaction.transactionType is Enums.getValue('TransactionTypes', 'provider')
    if item._id then 'Phiếu Thu' else 'Phiếu Chi'

  else if transaction.transactionType is Enums.getValue('TransactionTypes', 'customer')
    if item._id then 'Phiếu Chi' else 'Phiếu Thu'

formatOwnerSearch         = (item) -> "#{item.name}" if item
ownerSearch = (textSearch) ->
  transaction = Session.get('transactionDetail')
  return [] unless transaction

  selector = merchant: Merchant.getId(); options = {sort: {nameSearch: 1}}
  if(textSearch)
    regExp = Helpers.BuildRegExp(textSearch);
    selector = {$or: [
      {nameSearch: regExp, merchant: Merchant.getId()}
    ]}
  if transaction.transactionType is Enums.getValue('TransactionTypes', 'provider')
    Schema.providers.find(selector, options).fetch()
  else if transaction.transactionType is Enums.getValue('TransactionTypes', 'customer')
    Schema.customers.find(selector, options).fetch()

findOwner = (ownerId) ->
  transaction = Session.get('transactionDetail')
  if transaction.transactionType is Enums.getValue('TransactionTypes', 'provider')
    Schema.providers.findOne(ownerId)
  else if transaction.transactionType is Enums.getValue('TransactionTypes', 'customer')
    Schema.customers.findOne(ownerId)



lemon.defineApp Template.transaction,
  created: ->
    Session.set('transactionDetail', {transactionType: 1, receivable: false, amount: 0, description: ''})
    Session.set('transactionOwner')

  helpers:
    typeSelectOptions:
      query: (query) -> query.callback
        results: _.filter(Enums.TransactionTypes, (num) -> return num unless num._id is 2)
        text: '_id'
      initSelection: (element, callback) -> callback findTransactionType(Session.get('transactionDetail')?.transactionType)
      formatSelection: (item)-> formatDefaultSearch(item)
      formatResult: (item)-> formatDefaultSearch(item)
      placeholder: 'CHỌN NHÓM'
      minimumResultsForSearch: -1
      changeAction: (e) ->
        if e.added
          newTransaction = Session.get('transactionDetail')
          if newTransaction.transactionType is Enums.getValue('TransactionTypes', 'provider')
            newTransaction.receivable = if e.added._id then false else true
          else if newTransaction.transactionType is Enums.getValue('TransactionTypes', 'customer')
            newTransaction.receivable = unless e.added._id then false else true

          delete newTransaction.owner
          newTransaction.transactionType = e.added._id
          Session.set('transactionDetail', newTransaction)
      reactiveValueGetter: -> findTransactionType(Session.get('transactionDetail')?.transactionType)

    ownerSelectOptions:
      query: (query) -> query.callback
        results: ownerSearch(query.term)
        text: 'name'
      initSelection: (element, callback) -> callback findOwner(Session.get('transactionDetail')?.owner)
      formatSelection: formatOwnerSearch
      formatResult: formatOwnerSearch
      id: '_id'
      placeholder: 'KH Hoặc NCC'
      changeAction: (e) ->
        if e.added
          newTransaction = Session.get('transactionDetail')
          newTransaction.owner = e.added._id
          Session.set('transactionDetail', newTransaction)
      reactiveValueGetter: -> Session.get('transactionDetail')?.owner ? 'skyReset'

    receivableSelectOptions:
      query: (query) -> query.callback
        results: Enums.TransactionReceivable
        text: '_id'
      initSelection: (element, callback) -> callback findTransactionReceivable(Session.get('transactionDetail')?.receivable)
      formatSelection: (item)-> formatReceivableSearch(item)
      formatResult: (item)-> formatReceivableSearch(item)
      placeholder: 'LOẠI PHIẾU'
      minimumResultsForSearch: -1
      changeAction: (e) ->
        if e.added
          newTransaction = Session.get('transactionDetail')
          newTransaction.receivable = e.added._id
          Session.set('transactionDetail', newTransaction)
      reactiveValueGetter: -> findTransactionReceivable(Session.get('transactionDetail')?.receivable)

  events:
    "click .createTransaction":  (event, template) ->
      $payDescription = template.ui.$transactionDescription
      $payAmount      = template.ui.$transactionAmount
      transaction = Session.get('transactionDetail')

      if transaction.transactionType isnt undefined and
        transaction.receivable isnt undefined and
        transaction.owner and
        transaction.amount > 0 and
        transaction.description.length > 0

          Meteor.call(
            'createTransaction'
            transaction.owner
            transaction.amount
            null
            transaction.description
            transaction.transactionType
            transaction.receivable
            (error, result) -> console.log error, result
          )

          $payDescription.val(''); $payAmount.val('')
          transaction.amount = 0
          Session.set('transactionDetail', transaction)