scope = logics.providerManagement

lemon.defineApp Template.providerManagement,
  helpers:
    providerLists: ->
      selector = {}; options  = {sort: {nameSearch: 1}}; searchText = Session.get("providerManagementSearchFilter")
      if(searchText)
        regExp = Helpers.BuildRegExp(searchText);
        selector = {$or: [
          {nameSearch: regExp}
        ]}
      scope.providerLists = Schema.providers.find(selector, options).fetch()
      scope.providerLists

  created: ->
    Session.set("providerManagementSearchFilter", "")

  events:
    "keyup input[name='searchFilter']": (event, template) ->
      Helpers.deferredAction ->
        searchFilter  = template.ui.$searchFilter.val()
        providerSearch = Helpers.Searchify searchFilter
        Session.set("providerManagementSearchFilter", searchFilter)

        if event.which is 17 then console.log 'up'
        else if event.which is 38 then scope.ProviderSearchFindPreviousProvider(providerSearch)
        else if event.which is 40 then scope.ProviderSearchFindNextProvider(providerSearch)
        else
          scope.createNewProvider(template, providerSearch) if event.which is 13
          scope.providerManagementCreationMode(providerSearch)
      , "providerManagementSearchPeople"
      , 50

    "click .createProviderBtn": (event, template) ->
      fullText      = Session.get("providerManagementSearchFilter")
      providerSearch = Helpers.Searchify(fullText)
      scope.createNewProvider(template, providerSearch)
      ProviderSearch.search providerSearch

    "click .list .doc-item": (event, template) ->
      if userId = Meteor.userId()
        Meteor.subscribe('providerManagementCurrentProviderData', @_id)
        Meteor.users.update(userId, {$set: {'sessions.currentProvider': @_id}})


#    "click .excel-provider": (event, template) -> $(".excelFileSource").click()
#    "change .excelFileSource": (event, template) ->
#      if event.target.files.length > 0
#        console.log 'importing'
#        $excelSource = $(".excelFileSource")
#        $excelSource.parse
#          config:
#            complete: (results, file) ->
#              console.log file, results
#              Apps.Merchant.importFileProviderCSV(results.data)
#        $excelSource.val("")