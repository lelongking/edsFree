scope = logics.providerManagement
numericOption = {autoGroup: true, groupSeparator:",", radixPoint: ".", suffix: " VNĐ", integerDigits:11}

lemon.defineHyper Template.providerManagementImportsHistorySection,
  rendered: ->
    @ui.$payImportAmount.inputmask("numeric", numericOption)

  helpers:
    allImports: -> scope.findAllImport()
    oldDebts: -> scope.findOldDebt()
    hasOldDebts: -> scope.findOldDebt().length > 0
    debtTotalCash: ->
      if provider = Session.get('providerManagementCurrentProvider')
        provider.debtCash + provider.loanCash
      else 0

    transactionDescription: -> if Session.get("providerManagementOldDebt") then 'ghi chú nợ cũ' else 'ghi chú trả tiền'
    transactionStatus: -> if Session.get("providerManagementOldDebt") then 'Nợ Cũ' else 'Trả Tiền'
    showTransaction: -> if Session.get("providerManagementOldDebt") is undefined then 'display: none'

  events:
    "keyup input.transaction-field":  (event, template) ->
      scope.checkAllowCreateAndCreateTransaction(event, template)

    "click .deleteTransaction": (event, template) ->
      Meteor.call 'deleteTransaction', @_id

    "click .createTransaction": (event, template) ->
      scope.createTransactionOfImport(event, template)



