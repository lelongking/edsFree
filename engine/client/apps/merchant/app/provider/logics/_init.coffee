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
  scope.transactionFind = (parentId)-> Schema.transactions.find({parent: parentId}, {sort: {'version.createdAt': 1}})
  scope.findOldDebt = ->
    if providerId = Session.get("providerManagementProviderId")
      transaction = Schema.transactions.find({owner: providerId, parent:{$exists: false}}, {sort: {'version.createdAt': 1}})
      transactionCount = transaction.count(); count = 0
      transaction.map(
        (transaction) ->
          count += 1
          transaction.isLastTransaction = true if count is transactionCount
          transaction
      )
    else []

  scope.findAllImport = ->
    if providerId = Session.get("providerManagementProviderId")
      imports = Schema.imports.find({provider: providerId, importType: 4}).map(
        (item) -> item.transactions = scope.transactionFind(item._id);  item
      )
      returns = Schema.returns.find({owner: providerId, returnType: 4}).map(
        (item) -> item.transactions = scope.transactionFind(item._id);  item
      )
      _.sortBy imports.concat(returns), (item) -> item.version.createdAt
    else []

  scope.providerManagementCreationMode = () ->
  scope.ProviderSearchFindPreviousProvider = () ->
  scope.ProviderSearchFindNextProvider = () ->

