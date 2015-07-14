scope = logics.providerManagement

lemon.defineHyper Template.providerManagementImportsHistorySection,
  helpers:
    finalDebtBalance: -> @customImportDebt + @importDebt
    allowCreateCustomImport: -> if Session.get("allowCreateCustomImport") then '' else 'disabled'
    allowCreateTransactionOfImport: -> if Session.get("allowCreateTransactionOfImport") then '' else 'disabled'
    allowCreateTransactionOfCustomImport: -> if Session.get("allowCreateTransactionOfCustomImport") then '' else 'disabled'

    showExpandImportAndCustomImport: -> Session.get("showExpandImportAndCustomImport")
    isCustomImportModeEnabled: -> if Session.get("providerManagementCurrentProvider")?.customImportModeEnabled then "" else "display: none;"

    customImport: -> Schema.customImports.find({seller: Session.get("providerManagementCurrentProvider")?._id}, {sort: {debtDate: 1, 'version.createdAt': 1}})
    defaultImport: ->
      if provider = Session.get("providerManagementCurrentProvider")
        Schema.imports.find({provider: provider._id, finish: true, submitted: true}, {sort: {'version.createdAt': 1}})
    returnImport: ->
      if provider = Session.get("providerManagementCurrentProvider")
        Schema.returns.find({provider: provider._id, allowDelete: true})


  rendered: ->
    @ui.$customImportDebtDate.inputmask("dd/mm/yyyy")
    @ui.$paidDate.inputmask("dd/mm/yyyy")
    @ui.$payAmount.inputmask("numeric",   {autoGroup: true, groupSeparator:",", radixPoint: ".", suffix: " VNĐ", integerDigits:11})

    @ui.$payImportAmount.inputmask("numeric",   {autoGroup: true, groupSeparator:",", radixPoint: ".", suffix: " VNĐ", integerDigits:11})

  events:
    "click .expandImportAndCustomImport": ->
      if provider = Session.get("providerManagementCurrentProvider")
        limitExpand = Session.get("mySession").limitExpandImportAndCustomImport ? 5
        if provider.customImportModeEnabled
          currentRecords = Schema.customImports.find({seller: provider._id}).count()
        else
          currentRecords = Schema.customImports.find({seller: provider._id}).count() + Schema.imports.find({provider: provider._id, finish: true, submitted: true}).count()
        Meteor.subscribe('providerManagementData', provider._id, currentRecords, limitExpand)
        Session.set("providerManagementDataRecordCount", currentRecords)
        Session.set("providerManagementDataMaxCurrentRecords", currentRecords + limitExpand)

    "click .customImportModeDisable":  (event, template) ->
      if provider = Session.get("providerManagementCurrentProvider")
        scope.customImportModeDisable(provider._id)

#----Create-Custom-Import-----------------------------------------------------------------------------------------------
    "keydown .new-bill-field": (event, template) ->
      if provider = Session.get("providerManagementCurrentProvider") and event.which is 8 #Backspaces
        scope.checkAllowCreateCustomImport(template, provider)

    "input .new-bill-field": (event, template) ->
      if provider = Session.get("providerManagementCurrentProvider") #Input
        scope.checkAllowCreateCustomImport(template, provider)

    "keypress .new-bill-field": (event, template) ->
      if  Session.get("allowCreateCustomImport") and event.which is 13 #Enter
        scope.createCustomImport(template)

    "click .createCustomImport":  (event, template) ->
      if Session.get("allowCreateCustomImport") #Click
        scope.createCustomImport(template)

#-----Create-Transaction-Of-Custom-Import-------------------------------------------------------------------------------
    "keydown input.new-transaction-custom-import-field": (event, template) ->
      if provider = Session.get("providerManagementCurrentProvider") and event.which is 8
        scope.checkAllowCreateTransactionOfCustomImport(template, provider)

    "click .createTransactionOfCustomImport": (event, template) ->
      if Session.get("allowCreateTransactionOfCustomImport")
        scope.createTransactionOfCustomImport(template)

    "keypress input.new-transaction-custom-import-field": (event, template) ->
      if provider = Session.get("providerManagementCurrentProvider")
        scope.checkAllowCreateTransactionOfCustomImport(template, provider)
        if Session.get("allowCreateTransactionOfCustomImport") and event.which is 13
          scope.createTransactionOfCustomImport(template)

#----Create-Transaction-Of-Import-----------------------------------------------------------------------------------------
    "keydown input.new-transaction-import-field": (event, template) ->
      if provider = Session.get("providerManagementCurrentProvider")
        scope.checkAllowCreateTransactionOfImport(template, provider) if event.which is 8

    "click .createTransactionOfImport": (event, template) ->
      if provider = Session.get("providerManagementCurrentProvider")
        if Session.get("allowCreateTransactionOfImport")
          scope.createTransactionOfImport(template, provider)

    "keypress input.new-transaction-import-field": (event, template) ->
      if provider = Session.get("providerManagementCurrentProvider")
        scope.checkAllowCreateTransactionOfImport(template, provider)
        if Session.get("allowCreateTransactionOfImport") and event.which is 13
          scope.createTransactionOfImport(template, provider)



