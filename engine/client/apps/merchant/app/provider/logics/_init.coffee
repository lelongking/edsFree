logics.providerManagement = {}
Apps.Merchant.providerManagementInit = []
Apps.Merchant.providerManagementReactive = []

Apps.Merchant.providerManagementReactive.push (scope) ->
  scope.currentProvider = Schema.providers.findOne(Session.get('mySession').currentProvider)
  Session.set "providerManagementCurrentProvider", scope.currentProvider

Apps.Merchant.providerManagementInit.push (scope) ->
  scope.createNewProvider = (template, providerSearch) ->
    fullText    = Session.get("providerManagementSearchFilter")
    newProvider = Provider.splitName(fullText)

    if Provider.nameIsExisted(newProvider.name, Session.get("myProfile").merchant)
      template.ui.$searchFilter.notify("Khách hàng đã tồn tại.", {position: "bottom"})
    else
      newProviderId = Schema.providers.insert newProvider
      if Match.test(newProviderId, String)
        Meteor.users.update(Meteor.userId(), {$set: {'sessions.currentProvider': newProviderId}})

  scope.providerManagementCreationMode = () ->
  scope.ProviderSearchFindPreviousProvider = () ->
  scope.ProviderSearchFindNextProvider = () ->

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
