Enums = Apps.Merchant.Enums
scope = logics.transaction
numericOption = {autoGroup: true, groupSeparator:",", radixPoint: ".", suffix: " VNĐ", integerDigits:11}

lemon.defineApp Template.transactionOverviewSection,
  rendered: ->
    @ui.$transactionAmount.inputmask("numeric", numericOption) if @ui.$transactionAmount

  helpers:
    owner: -> Session.get('transactionOwner')
    transaction: ->
      owner       = Session.get('transactionOwner')
      transaction = Session.get('transactionDetail')
      owner = {totalCash: 0} unless owner
      if transaction.transactionType is Enums.getValue('TransactionTypes', 'provider')
        transaction.typeDisplay = 'NHÀ CUNG CẤP'
        if transaction.receivable
          transaction.receivableDisplay = 'TIỀN THU'
          transaction.finalDebtCash = owner.totalCash + transaction.amount
        else
          transaction.receivableDisplay = 'TIỀN CHI'
          transaction.finalDebtCash = owner.totalCash - transaction.amount

      else if transaction.transactionType is Enums.getValue('TransactionTypes', 'customer')
        transaction.typeDisplay = 'KHÁCH HÀNG'
        if transaction.receivable
          transaction.receivableDisplay = 'TIỀN CHI'
          transaction.finalDebtCash = owner.totalCash + transaction.amount
        else
          transaction.receivableDisplay = 'TIỀN THU'
          transaction.finalDebtCash = owner.totalCash - transaction.amount

      if transaction.owner and transaction.description.length > 0 and transaction.amount > 0
        Session.set('transactionCreateNewIsDisabled', '')
      else
        Session.set('transactionCreateNewIsDisabled', 'disabled')

      transaction




  events:
    "keyup input.transaction-field":  (event, template) ->
      payAmount      = parseInt($(template.find("[name='transactionAmount']")).inputmask('unmaskedvalue'))
      payDescription = template.ui.$transactionDescription.val()
      if transaction = Session.get('transactionDetail')
        transaction.amount = if !isNaN(payAmount) then Math.abs(payAmount) else 0
        transaction.description = payDescription
        Session.set('transactionDetail', transaction)

#      $payDescription = template.ui.$paySaleDescription
#      $payAmount      = template.ui.$paySaleAmount
#      payAmount       = parseInt($(template.find("[name='paySaleAmount']")).inputmask('unmaskedvalue'))
#      description     = $payDescription.val()
#
#      if !isNaN(payAmount) and payAmount != 0
#        ownerId         = scope.currentCustomer._id
#        debitCash       = Math.abs(payAmount)
#        transactionType = Enums.getValue('TransactionTypes', 'customer')
#        receivable      = Session.get("customerManagementOldDebt")
#        console.log debitCash
#        Session.set("allowCreateTransactionOfCustomer", false)
#        Session.set("customerManagementOldDebt")
#        $payDescription.val(''); $payAmount.val('')
#        Meteor.call 'createTransaction', ownerId, debitCash, null, description, transactionType, receivable, (error, result) ->