Enums = Apps.Merchant.Enums
logics.customerGroup = {}
Apps.Merchant.customerGroupInit = []
Apps.Merchant.customerGroupReactive = []

Apps.Merchant.customerGroupReactive.push (scope) ->
  customerGroup = Schema.customerGroups.findOne(Session.get('mySession').currentCustomerGroup)
  customerGroup = Schema.customerGroups.findOne({isBase: true, merchant: Merchant.getId()}) unless customerGroup
  if customerGroup
    customerGroup.customerCount = if customerGroup.customers then customerGroup.customers.length else 0
    scope.currentCustomerGroup = customerGroup
    Session.set "currentCustomerGroup", scope.currentCustomerGroup
    Session.set "customerSelectLists", Session.get('mySession').customerSelected?[Session.get('currentCustomerGroup')._id] ? []
    $(".changeCustomer").select2("readonly", Session.get("customerSelectLists").length is 0)

Apps.Merchant.customerGroupInit.push (scope) ->
  scope.resetSearchFilter = (template) ->
    template.ui.$searchFilter.val('')
    Session.set("customerGroupSearchFilter", "")
    Session.set("customerGroupCreationMode", false)

  scope.checkAllowUpdateOverviewCustomerGroup = (template) ->
    Session.set "customerGroupShowEditCommand",
      template.ui.$customerGroupName.val() isnt Session.get("currentCustomerGroup").name or
        template.ui.$customerGroupDescription.val() isnt (Session.get("currentCustomerGroup").description ? '')


  scope.searchFindPreviousCustomerGroup = (customerSearch) ->
    if previousRow = scope.customerGroupLists.getPreviousBy('_id', Session.get('mySession').currentCustomer)
      Meteor.users.update(Meteor.userId(), {$set: {'sessions.currentCustomer': previousRow._id}})


  scope.searchFindNextCustomerGroup = (customerSearch) ->
    if nextRow = scope.customerGroupLists.getNextBy('_id', Session.get('mySession').currentCustomer)
      Meteor.users.update(Meteor.userId(), {$set: {'sessions.currentCustomer': nextRow._id}})