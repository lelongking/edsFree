logics.providerManagement = {}
Apps.Merchant.providerManagementInit = []
Apps.Merchant.providerManagementReactive = []


Apps.Merchant.providerManagementReactive.push (scope) ->
  scope.currentProvider = Schema.providers.findOne(Session.get('mySession').currentProvider)
  Session.set "providerManagementCurrentProvider", scope.currentProvider

  providerId = if scope.currentProvider?._id then scope.currentProvider._id else false
  if Session.get("providerManagementProviderId") isnt providerId
    Session.set "providerManagementProviderId", providerId



Apps.Merchant.providerManagementInit.push (scope) ->
  scope.resetShowEditCommand = -> Session.set "providerManagementShowEditCommand"
  scope.findAllImport = ->
    if providerId = Session.get("providerManagementProviderId")
      Schema.imports.find({provider: providerId, importType: 4}, {sort: {'version.createdAt': 1}})
    else []

  scope.providerManagementCreationMode = () ->
  scope.ProviderSearchFindPreviousProvider = () ->
  scope.ProviderSearchFindNextProvider = () ->

