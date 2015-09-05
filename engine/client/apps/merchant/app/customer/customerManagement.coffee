scope = logics.customerManagement

lemon.defineApp Template.customerManagement,
  helpers:
    creationMode: -> Session.get("customerManagementCreationMode")
    currentCustomer: -> Session.get("customerManagementCurrentCustomer")
    customerLists: ->
      selector = {}; options  = {sort: {nameSearch: 1}}; searchText = Session.get("customerManagementSearchFilter")
      if(searchText)
        regExp = Helpers.BuildRegExp(searchText);
        selector = {$or: [
          {nameSearch: regExp}
        ]}

      if Session.get('myProfile')?.roles is 'seller'
        if(searchText)
          selector.$or[0]._id = $in: Session.get('myProfile').customers
        else
          selector = {_id: {$in: Session.get('myProfile').customers}}

      scope.customerLists = Schema.customers.find(selector, options).fetch()
      scope.customerLists

  created: ->
    Session.set("customerManagementSearchFilter", "")

  events:
    # search customer and create customer if not search found
    "keyup input[name='searchFilter']": (event, template) ->
      Helpers.deferredAction ->
        searchFilter  = template.ui.$searchFilter.val()
        customerSearch = Helpers.Searchify searchFilter
        Session.set("customerManagementSearchFilter", searchFilter)

        if event.which is 17 then console.log 'up'
        else if event.which is 38 then scope.CustomerSearchFindPreviousCustomer(customerSearch)
        else if event.which is 40 then scope.CustomerSearchFindNextCustomer(customerSearch)
        else
          if User.hasManagerRoles()
            scope.createNewCustomer(template, customerSearch) if event.which is 13
            setTimeout (-> scope.customerManagementCreationMode(customerSearch); return), 300
          else
            Session.set("customerManagementCreationMode", false)

      , "customerManagementSearchPeople"
      , 50

    "click .createCustomerBtn": (event, template) ->
      if User.hasManagerRoles()
        fullText      = Session.get("customerManagementSearchFilter")
        customerSearch = Helpers.Searchify(fullText)
        scope.createNewCustomer(template, customerSearch)
        CustomerSearch.search customerSearch

    "click .list .doc-item": (event, template) ->
      if userId = Meteor.userId()
#        Meteor.subscribe('customerManagementCurrentCustomerData', @_id)
        Meteor.users.update(userId, {$set: {'sessions.currentCustomer': @_id}})
        Session.set('customerManagementIsShowCustomerDetail', false)

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
