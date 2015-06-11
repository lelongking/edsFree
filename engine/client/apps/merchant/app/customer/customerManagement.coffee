scope = logics.customerManagement

lemon.defineApp Template.customerManagement,
  creationMode: -> Session.get("customerManagementCreationMode")
  currentCustomer: -> Session.get("customerManagementCurrentCustomer")
  avatarUrl: -> if @avatar then AvatarImages.findOne(@avatar)?.url() else undefined
  activeClass:-> if Session.get("customerManagementCurrentCustomer")?._id is @._id then 'active' else ''


#  finalDebtBalance: -> Session.get("customerManagementCurrentCustomer")?.customSaleDebt + Session.get("customerManagementCurrentCustomer")?.saleDebt
#  rendered: -> $(".nano").nanoScroller()

  created: ->
#    permission = Role.hasPermission(Session.get("myProfile"), Apps.Merchant.TempPermissions.customerStaff.key)
#    if !permission then Router.go('/merchant')
#    lemon.dependencies.resolve('customerManagement')

    CustomerSearch.search('')
    Session.set("customerManagementSearchFilter", "")

#    if Session.get("mySession")
#      currentCustomer = Session.get("mySession").currentCustomerManagementSelection
#      limitExpand = Session.get("mySession").limitExpandSaleAndCustomSale ? 5
#      if !currentCustomer
#        if customer = Schema.customers.findOne()
#          UserSession.set("currentCustomerManagementSelection", customer._id)
#          Meteor.subscribe('customerManagementData', customer._id, 0, limitExpand)
#          Session.set("customerManagementDataMaxCurrentRecords", limitExpand)
#          Session.set("customerManagementCurrentCustomer", customer)
#      else
#        Meteor.subscribe('customerManagementData', currentCustomer, 0, limitExpand)
#        Session.set("customerManagementDataMaxCurrentRecords", limitExpand)
#        Session.set("customerManagementCurrentCustomer", Schema.customers.findOne(currentCustomer))

  events:
    "keyup input[name='searchFilter']": (event, template) ->
      Helpers.deferredAction ->
        searchFilter  = template.ui.$searchFilter.val()
        customerSearch = Helpers.Searchify searchFilter
        Session.set("customerManagementSearchFilter", searchFilter)

        if event.which is 17 then console.log 'up'
        else if event.which is 38 then scope.CustomerSearchFindPreviousCustomer(customerSearch)
        else if event.which is 40 then scope.CustomerSearchFindNextCustomer(customerSearch)
        else
          scope.createNewCustomer(template, customerSearch) if event.which is 13
          CustomerSearch.search customerSearch
          scope.customerManagementCreationMode(customerSearch)
      , "customerManagementSearchPeople"

    "click .createCustomerBtn": (event, template) ->
      fullText      = Session.get("customerManagementSearchFilter")
      customerSearch = Helpers.Searchify(fullText)
      scope.createNewCustomer(template, customerSearch)
      CustomerSearch.search customerSearch

    "click .inner.caption": (event, template) ->
      if userId = Meteor.userId()
        Meteor.subscribe('customerManagementCurrentCustomerData', @_id)
        Meteor.users.update(userId, {$set: {'sessions.currentCustomer': @_id}})

#        Schema.userSessions.update(Session.get("mySession")._id, {$set: {currentCustomerManagementSelection: @_id}})
#        limitExpand = Session.get("mySession").limitExpandSaleAndCustomSale ? 5
#        if customer = Schema.customers.findOne(@_id)
#          countRecords = Schema.customSales.find({buyer: customer._id}).count()
#          countRecords += Schema.sales.find({buyer: customer._id}).count() if customer.customSaleModeEnabled is false
#          if countRecords is 0
#            Meteor.subscribe('customerManagementData', customer._id, 0, limitExpand)
#            Session.set("customerManagementDataMaxCurrentRecords", limitExpand)
#          else
#            Session.set("customerManagementDataMaxCurrentRecords", countRecords)
#          Session.set("customerManagementCurrentCustomer", customer)
#
#        Session.set("allowCreateCustomSale", false)
#        Session.set("allowCreateTransactionOfCustomSale", false)


#    "click .excel-customer": (event, template) -> $(".excelFileSource").click()
#    "change .excelFileSource": (event, template) ->
#      if event.target.files.length > 0
#        console.log 'importing'
#        $excelSource = $(".excelFileSource")
#        $excelSource.parse
#          config:
#            complete: (results, file) ->
#              console.log file, results
#              Apps.Merchant.importFileCustomerCSV(results.data)
#        $excelSource.val("")
