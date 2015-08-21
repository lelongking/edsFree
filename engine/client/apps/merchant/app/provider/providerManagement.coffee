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
      scope.searchOrCreateProviderByInput(event, template)

    "click .createProviderBtn": (event, template) ->
      scope.createProviderByBtn(event, template)

    "click .list .doc-item": (event, template) ->
      Provider.selectProvider(@_id)
      Session.set('providerManagementIsShowProviderDetail', false)

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