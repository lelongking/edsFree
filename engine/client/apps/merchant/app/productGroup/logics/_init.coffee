Enums = Apps.Merchant.Enums
logics.productGroup = {}
Apps.Merchant.productGroupInit = []
Apps.Merchant.productGroupReactive = []

Apps.Merchant.productGroupReactive.push (scope) ->
  productGroup = Schema.productGroups.findOne(Session.get('mySession').currentProductGroup)
  productGroup = Schema.productGroups.findOne({isBase: true, merchant: Merchant.getId()}) unless productGroup
  if productGroup
    productGroup.productCount = if productGroup.products then productGroup.products.length else 0
    scope.currentProductGroup = productGroup
    Session.set "currentProductGroup", scope.currentProductGroup
    Session.set "productSelectLists", Session.get('mySession').productSelected?[Session.get('currentProductGroup')._id] ? []



Apps.Merchant.productGroupInit.push (scope) ->
  scope.resetSearchFilter = (template) ->
    template.ui.$searchFilter.val('')
    Session.set("productGroupSearchFilter", "")
    Session.set("productGroupCreationMode", false)

  scope.checkAllowUpdateOverviewProductGroup = (template) ->
    Session.set "productGroupShowEditCommand",
      template.ui.$productGroupName.val() isnt Session.get("currentProductGroup").name or
        template.ui.$productGroupDescription.val() isnt (Session.get("currentProductGroup").description ? '')


  scope.searchFindPreviousProductGroup = (productSearch) ->
    if previousRow = scope.productGroupLists.getPreviousBy('_id', Session.get('mySession').currentProduct)
      Meteor.users.update(Meteor.userId(), {$set: {'sessions.currentProduct': previousRow._id}})


  scope.searchFindNextProductGroup = (productSearch) ->
    if nextRow = scope.productGroupLists.getNextBy('_id', Session.get('mySession').currentProduct)
      Meteor.users.update(Meteor.userId(), {$set: {'sessions.currentProduct': nextRow._id}})