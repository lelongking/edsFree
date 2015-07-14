scope = logics.providerManagement
numericOption = {autoGroup: true, groupSeparator:",", radixPoint: ".", suffix: " VNĐ", integerDigits:11}

lemon.defineHyper Template.providerManagementImportsHistorySection,
  rendered: ->
    @ui.$payImportAmount.inputmask("numeric", numericOption)

  helpers:
    allImports: -> scope.findAllImport()
    debtTotalCash: -> Session.get('providerManagementCurrentProvider')?.debtCash ? 0

  events:
    "keydown input.transaction-field":  (event, template) -> scope.checkAllowCreateTransactionOfImport(event, template)
    "keypress input.transaction-field": (event, template) -> scope.createTransactionOfImport(event, template) if event.which is 13
    "click .createTransaction":         (event, template) -> scope.createTransactionOfImport(event, template)



