Apps.Merchant.providerManagementInit.push (scope) ->
#-----------------Edit Provider-----------------------------------
  scope.createNewProvider = (template, providerSearch) ->
    fullText    = Session.get("providerManagementSearchFilter")
    newProvider = Provider.splitName(fullText)

    if Provider.nameIsExisted(newProvider.name, Session.get("myProfile").merchant)
      template.ui.$searchFilter.notify("Khách hàng đã tồn tại.", {position: "bottom"})
    else
      newProviderId = Schema.providers.insert newProvider
      if Match.test(newProviderId, String)
        Meteor.users.update(Meteor.userId(), {$set: {'sessions.currentProvider': newProviderId}})

  scope.editProvider = (template) ->
    provider = Session.get("providerManagementCurrentProvider")
    if provider and Session.get("providerManagementShowEditCommand")
      name  = template.ui.$providerName.val()
      phone = template.ui.$providerPhone.val()
      address = template.ui.$providerAddress.val()

      editOptions = {}
      editOptions.phone = phone if phone.length > 0
      editOptions.address = address if address.length > 0
      if name.length > 0
        editOptions.name = name
        providerFound = Schema.providers.findOne {name: name, parentMerchant: provider.parentMerchant}

      if name.length is 0
        template.ui.$providerName.notify("Tên nhà phân phối không thể để trống.", {position: "right"})
      else if providerFound and providerFound._id isnt provider._id
        template.ui.$providerName.notify("Tên nhà phân phối đã tồn tại.", {position: "right"})
        template.ui.$providerName.val name
        Session.set("providerManagementShowEditCommand", false)
      else
        Schema.providers.update provider._id, {$set: editOptions}, (error, result) -> if error then console.log error
        template.ui.$providerName.val editOptions.name
        Session.set("providerManagementShowEditCommand", false)

  scope.checkAllowUpdateProviderOverview = (template) ->
    Session.set "providerManagementShowEditCommand",
      template.ui.$providerName.val() isnt Session.get("providerManagementCurrentProvider").name or
        template.ui.$providerPhone.val() isnt (Session.get("providerManagementCurrentProvider").phone ? '') or
        template.ui.$providerAddress.val() isnt (Session.get("providerManagementCurrentProvider").address ? '')

Apps.Merchant.providerManagementInit.push (scope) ->
#-----------------Create Transaction-----------------------------------
  scope.checkAllowCreateTransactionOfImport = (event, template) ->
    if event.which is 8 and Session.get("providerManagementCurrentProvider")
      payAmount = parseInt($(template.find("[name='payImportAmount']")).inputmask('unmaskedvalue'))
      if payAmount != 0 and !isNaN(payAmount)
        Session.set("allowCreateTransactionOfImport", true)
      else
        Session.set("allowCreateTransactionOfImport", false)

  scope.createTransactionOfImport = (event, template) ->
    scope.checkAllowCreateTransactionOfImport(event, template)

    if Session.get("allowCreateTransactionOfImport")
      $payDescription = template.ui.$payImportDescription
      $payAmount = template.ui.$payImportAmount
      payAmount = parseInt($(template.find("[name='payImportAmount']")).inputmask('unmaskedvalue'))

      if !isNaN(payAmount) and payAmount != 0
        Meteor.call('createNewReceiptCashOfImport', distributor._id, Math.abs(payAmount), $payDescription.val())
        Meteor.call 'reCalculateMetroSummaryTotalPayableCash'
        Session.set("allowCreateTransactionOfImport", false)
        $payDescription.val(''); $payAmount.val('')
        limitExpand    = Session.get("distributorManagementDataMaxCurrentRecords")
        currentRecords = Session.get("distributorManagementDataRecordCount")
        Meteor.subscribe('distributorManagementData', distributor._id, currentRecords, limitExpand)