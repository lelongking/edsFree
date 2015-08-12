Enums = Apps.Merchant.Enums
scope = logics.transaction
numericOption = {autoGroup: true, groupSeparator:",", radixPoint: ".", suffix: " VNĐ", integerDigits:11}

lemon.defineApp Template.bankPaymentVoucherTransactionHistorySection,
  rendered: ->
  helpers:
    details: ->
      Schema.transactions.find({
        merchant          : Merchant.getId()
        transactionType   : Enums.getValue('TransactionTypes', 'provider')
        paidBalanceChange : {$gt: 0}
      },{$sort:{'version.createdAt':1}}).map(
        (transaction)->
          transaction.ownerName = Schema.providers.findOne(transaction.owner).name
          transaction.staffName = Meteor.users.findOne(transaction.creator)?.profile.name
          transaction
      )

    detailCount: ->
      Schema.transactions.find({
        merchant          : Merchant.getId()
        transactionType   : Enums.getValue('TransactionTypes', 'provider')
        paidBalanceChange : {$gt: 0}
      }).count()




#  events:
#    "keyup input.transaction-field":  (event, template) ->
#      payAmount      = parseInt($(template.find("[name='transactionAmount']")).inputmask('unmaskedvalue'))
#      payDescription = template.ui.$transactionDescription.val()
#      if transaction = Session.get('transactionDetail')
#        transaction.amount = if !isNaN(payAmount) then Math.abs(payAmount) else 0
#        transaction.description = payDescription
#        Session.set('transactionDetail', transaction)