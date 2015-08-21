Enums = Apps.Merchant.Enums
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
      imports = Schema.imports.find({
        provider  : providerId
        importType: Enums.getValue('ImportTypes', 'success')
      }).map(
        (item) ->
          item.transactions = scope.transactionFind(item._id).fetch()
          item.transactions[item.transactions.length-1].isLastTransaction = true if item.transactions.length > 0
          item
      )

      returns = Schema.returns.find({
        owner       : providerId
        returnType  : Enums.getValue('ReturnTypes', 'provider')
        returnStatus: Enums.getValue('ReturnStatus', 'success')
      }).map(
        (item) ->
          item.transactions = scope.transactionFind(item._id).fetch()
          item.transactions[item.transactions.length-1].isLastTransaction = true if item.transactions.length > 0
          item
      )

      dataSource = _.sortBy(imports.concat(returns), (item) -> item.successDate)
      classColor = false
      for item in dataSource
        item.classColor = classColor
        classColor = !classColor
      dataSource

    else []

  scope.providerManagementCreationMode = () ->
    if Session.get("providerManagementSearchFilter").length > 0
      if scope.providerLists.length is 0 then nameIsExisted = true
      else if scope.providerLists.length is 1
        nameIsExisted = scope.providerLists[0].name isnt Session.get("providerManagementSearchFilter")
    Session.set("providerManagementCreationMode", nameIsExisted)


  scope.ProviderSearchFindPreviousProvider = () ->
  scope.ProviderSearchFindNextProvider = () ->

