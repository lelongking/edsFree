scope = logics.providerManagement
numericOption = {autoGroup: true, groupSeparator:",", radixPoint: ".", suffix: " VNĐ", integerDigits:11}

lemon.defineHyper Template.providerManagementImportsHistorySection,
  rendered: ->
    @ui.$payImportAmount.inputmask("numeric", numericOption)

  helpers:
    allImports: -> scope.findAllImport()
    oldDebts: -> scope.findOldDebt()
    hasOldDebts: -> scope.findOldDebt().length > 0

    isDelete: -> moment().diff(@version.createdAt ? new Date(), 'days') < 1

    totalDebtCash: ->
      if provider = Session.get('providerManagementCurrentProvider')
        provider.debtCash + provider.loanCash
      else 0

    totalPaidCash: ->
      if provider = Session.get('providerManagementCurrentProvider')
        (unless provider.paidCash is undefined then provider.paidCash else 0) + (unless provider.returnCash is undefined then provider.returnCash else 0)
      else 0

    transactionDescription: -> if Session.get("providerManagementOldDebt") then 'ghi chú nợ tiền' else 'ghi chú trả tiền'
    transactionStatus: -> if Session.get("providerManagementOldDebt") then 'Nợ Tiền' else 'Trả Tiền'
    showTransaction: -> if Session.get("providerManagementOldDebt") is undefined then 'display: none'

  events:
    "keyup input.transaction-field":  (event, template) ->
      scope.checkAllowCreateAndCreateTransaction(event, template)

    "click .deleteTransaction": (event, template) ->
      Meteor.call 'deleteTransaction', @_id

    "click .createTransaction": (event, template) ->
      scope.createTransactionOfProvider(event, template)



