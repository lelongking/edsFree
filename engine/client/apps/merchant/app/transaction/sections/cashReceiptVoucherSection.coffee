Enums = Apps.Merchant.Enums
scope = logics.transaction
numericOption = {autoGroup: true, groupSeparator:",", radixPoint: ".", suffix: " VNĐ", integerDigits:11}

lemon.defineApp Template.cashReceiptVoucherTransactionHistorySection,
  rendered: ->
  helpers:
    details: ->
      Schema.transactions.find({
        merchant        : Merchant.getId()
        transactionType : Enums.getValue('TransactionTypes', 'customer')
        isUseCode       : true
        isBeginCash     : false
      },{$sort:{'version.createdAt':1}}).map(
        (transaction)->
          transaction.ownerName = Schema.customers.findOne(transaction.owner).name
          transaction.staffName = Meteor.users.findOne(transaction.creator)?.profile.name
          transaction
      )

    detailCount: ->
      Schema.transactions.find({
        merchant        : Merchant.getId()
        transactionType : Enums.getValue('TransactionTypes', 'customer')
        isBeginCash     : false
        isUseCode       : true
      }).count()


    transactionCash: ->
      if @status is Enums.getValue('TransactionStatuses', 'tracking')
        @debtBalanceChange
      else if @status is Enums.getValue('TransactionStatuses', 'closed')
        @paidBalanceChange


#  events:
#    "keyup input.transaction-field":  (event, template) ->
#      payAmount      = parseInt($(template.find("[name='transactionAmount']")).inputmask('unmaskedvalue'))
#      payDescription = template.ui.$transactionDescription.val()
#      if transaction = Session.get('transactionDetail')
#        transaction.amount = if !isNaN(payAmount) then Math.abs(payAmount) else 0
#        transaction.description = payDescription
#        Session.set('transactionDetail', transaction)