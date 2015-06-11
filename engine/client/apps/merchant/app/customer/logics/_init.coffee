logics.customerManagement = {}
Apps.Merchant.customerManagementInit = []
Apps.Merchant.customerManagementReactive = []

Apps.Merchant.customerManagementReactive.push (scope) ->
  scope.currentCustomer = Schema.customers.findOne(Session.get('mySession').currentCustomer)
  Session.set "customerManagementCurrentCustomer", scope.currentCustomer


Apps.Merchant.customerManagementInit.push (scope) ->
  scope.customerManagementCreationMode = (customerSearch)->
    if CustomerSearch.getCurrentQuery().length > 0
      if CustomerSearch.history[customerSearch].data?.length is 0 then nameIsExisted = true
      else if CustomerSearch.history[customerSearch].data?.length is 1
        nameIsExisted = CustomerSearch.history[customerSearch].data[0].name isnt Session.get("customerManagementSearchFilter")
    Session.set("customerManagementCreationMode", nameIsExisted)

  scope.createNewCustomer = (template, customerSearch) ->
    fullText    = Session.get("customerManagementSearchFilter")
    newCustomer = Customer.splitName(fullText)

    if Customer.nameIsExisted(newCustomer.name, Session.get("myProfile").merchant)
      template.ui.$searchFilter.notify("Khách hàng đã tồn tại.", {position: "bottom"})
    else
      newCustomerId = Schema.customers.insert newCustomer
      if Match.test(newCustomerId, String)
        Meteor.users.update(Meteor.userId(), {$set: {'sessions.currentCustomer': newCustomerId}})
        CustomerSearch.cleanHistory()

  scope.CustomerSearchFindPreviousCustomer = (customerSearch) ->
    if previousRow = CustomerSearch.history[customerSearch].data.getPreviousBy('_id', Session.get('mySession').currentCustomer)
      Meteor.users.update(Meteor.userId(), {$set: {'sessions.currentCustomer': previousRow._id}})

  scope.CustomerSearchFindNextCustomer = (customerSearch) ->
    if nextRow = CustomerSearch.history[customerSearch].data.getNextBy('_id', Session.get('mySession').currentCustomer)
      Meteor.users.update(Meteor.userId(), {$set: {'sessions.currentCustomer': nextRow._id}})
