scope = logics.customerManagement

lemon.defineApp Template.customerManagement,
  helpers:
    creationMode: -> Session.get("customerManagementCreationMode")
    currentCustomer: -> Session.get("customerManagementCurrentCustomer")
    debtTotalCash: -> @debtCash + @loanCash
    customerLists: ->
      selector = {}; options  = {sort: {nameSearch: 1}}; searchText = Session.get("customerManagementSearchFilter")
      if(searchText)
        regExp = Helpers.BuildRegExp(searchText);
        selector = {$or: [
          {name: regExp}
        ]}
      scope.customerLists = Schema.customers.find(selector, options).fetch()
      scope.customerLists

  created: ->
    Session.set("customerManagementSearchFilter", "")

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
          scope.customerManagementCreationMode(customerSearch)
      , "customerManagementSearchPeople"
      , 50

    "click .createCustomerBtn": (event, template) ->
      fullText      = Session.get("customerManagementSearchFilter")
      customerSearch = Helpers.Searchify(fullText)
      scope.createNewCustomer(template, customerSearch)
      CustomerSearch.search customerSearch

    "click .list .doc-item": (event, template) ->
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
