Enums = Apps.Merchant.Enums
Apps.Merchant.customerManagementInit.push (scope) ->
#-------------------Edit Customer-----------------------
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

  scope.checkAllowUpdateOverview = (template) ->
    Session.set "customerManagementShowEditCommand",
      template.ui.$customerName.val() isnt Session.get("customerManagementCurrentCustomer").name or
        template.ui.$customerPhone.val() isnt (Session.get("customerManagementCurrentCustomer").profiles.phone ? '') or
        template.ui.$customerAddress.val() isnt (Session.get("customerManagementCurrentCustomer").profiles.address ? '')

  scope.editCustomer = (template) ->
    customer = Session.get("customerManagementCurrentCustomer")
    if customer and Session.get("customerManagementShowEditCommand")
      name    = template.ui.$customerName.val()
      phone   = template.ui.$customerPhone.val()
      address = template.ui.$customerAddress.val()

      return if name.replace("(", "").replace(")", "").trim().length < 2
      editOptions = Helpers.splitName(name)
      editOptions['profiles.phone'] = phone if phone.length > 0
      editOptions['profiles.address'] = address if address.length > 0

      console.log editOptions

      if editOptions.name.length > 0
        customerFound = Schema.customers.findOne {name: editOptions.name, parentMerchant: customer.parentMerchant}

      if editOptions.name.length is 0
        template.ui.$customerName.notify("Tên khách hàng không thể để trống.", {position: "right"})
      else if customerFound and customerFound._id isnt customer._id
        template.ui.$customerName.notify("Tên khách hàng đã tồn tại.", {position: "right"})
        template.ui.$customerName.val editOptions.name
        Session.set("customerManagementShowEditCommand", false)
      else
        Schema.customers.update customer._id, {$set: editOptions}, (error, result) -> if error then console.log error
        template.ui.$customerName.val editOptions.name
        Session.set("customerManagementShowEditCommand", false)

        CustomerSearch.cleanHistory()
        CustomerSearch.search(CustomerSearch.getCurrentQuery())


Apps.Merchant.customerManagementInit.push (scope) ->
#-------------------Edit Transaction-----------------------
  scope.checkAllowCreateAndCreateTransaction = (event, template) ->
    if event.which is 13 then scope.createTransactionOfCustomer(event, template)
    else scope.checkAllowCreateTransactionOfCustomer(event, template)

  scope.checkAllowCreateTransactionOfCustomer = (event, template) ->
    payAmount = parseInt($(template.find("[name='paySaleAmount']")).inputmask('unmaskedvalue'))
    if payAmount != 0 and !isNaN(payAmount)
      Session.set("allowCreateTransactionOfCustomer", true)
    else
      Session.set("allowCreateTransactionOfCustomer", false)

  scope.createTransactionOfCustomer = (event, template) ->
    scope.checkAllowCreateTransactionOfCustomer(event, template)
    if Session.get("allowCreateTransactionOfCustomer")
      $payDescription = template.ui.$paySaleDescription
      $payAmount      = template.ui.$paySaleAmount
      payAmount       = parseInt($(template.find("[name='paySaleAmount']")).inputmask('unmaskedvalue'))
      description     = $payDescription.val()

      if !isNaN(payAmount) and payAmount != 0
        ownerId         = scope.currentCustomer._id
        debitCash       = Math.abs(payAmount)
        transactionType = Enums.getValue('TransactionTypes', 'customer')
        console.log debitCash
        Meteor.call 'createTransaction', ownerId, debitCash, null, description, transactionType, (error, result) ->
          Session.set("allowCreateTransactionOfCustomer", false)
          $payDescription.val(''); $payAmount.val('')