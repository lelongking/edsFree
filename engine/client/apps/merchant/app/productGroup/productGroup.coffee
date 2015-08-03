scope = logics.productGroup

lemon.defineApp Template.productGroup,
  helpers:
    productGroupLists: ->
      console.log 'reactive....'
      selector = {}; options  = {sort: {isBase: 1, nameSearch: 1}}; searchText = Session.get("productGroupSearchFilter")
      if(searchText)
        regExp = Helpers.BuildRegExp(searchText);
        selector = {$or: [
          {name: regExp}
        ]}
      scope.productGroupLists = Schema.productGroups.find(selector, options).fetch()
      scope.productGroupLists

  created: ->
    Session.set("productGroupSearchFilter", "")
    Session.set("productGroupCreationMode", false)

  events:
    "keyup input[name='searchFilter']": (event, template) ->
      Helpers.deferredAction ->
        searchFilter  = template.ui.$searchFilter.val()
        Session.set("productGroupSearchFilter", searchFilter)

        if event.which is 17 then console.log 'up'
        else if event.which is 27 then scope.resetSearchFilter(template)
        else if event.which is 38 then scope.searchFindPreviousProductGroup()
        else if event.which is 40 then scope.searchFindNextProductGroup()
        else
          if User.hasManagerRoles()
            nameIsExisted = ProductGroup.nameIsExisted(Session.get("productGroupSearchFilter"), Session.get("myProfile").merchant)
            Session.set("productGroupCreationMode", !nameIsExisted)
            scope.createNewProductGroup(template) if event.which is 13
          else
            Session.set("productGroupCreationMode", false)

      , "productGroupSearchPeople"
      , 50

    "click .createProductGroupBtn": (event, template) -> scope.createNewProductGroup(template) if User.hasManagerRoles()
    "click .list .doc-item": (event, template) -> ProductGroup.setSessionProductGroup(@_id)