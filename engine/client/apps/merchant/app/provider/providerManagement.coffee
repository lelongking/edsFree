scope = logics.providerManagement

lemon.defineApp Template.providerManagement,
  avatarUrl: -> if @avatar then AvatarImages.findOne(@avatar)?.url() else undefined
  currentProvider: -> Session.get("providerManagementCurrentProvider")
  activeClass:-> if Session.get("providerManagementCurrentProvider")?._id is @._id then 'active' else ''
  creationMode: -> Session.get("providerCreationMode")

#  rendered: -> $(".nano").nanoScroller()
  created: ->
    ProviderSearch.search('')
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
          ProviderSearch.search providerSearch
          scope.providerManagementCreationMode(providerSearch)
      , "providerManagementSearchPeople"
      , 50

    "click .createProviderBtn": (event, template) ->
      fullText      = Session.get("providerManagementSearchFilter")
      providerSearch = Helpers.Searchify(fullText)
      scope.createNewProvider(template, providerSearch)
      ProviderSearch.search providerSearch

    "click .inner.caption": (event, template) ->
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