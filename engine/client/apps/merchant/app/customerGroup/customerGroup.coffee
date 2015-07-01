scope = logics.customerGroup

lemon.defineApp Template.customerGroup,
  customerGroupLists: ->
    console.log 'reactive....'
    selector = {}; options  = {sort: {isBase: 1, nameSearch: 1}}; searchText = Session.get("customerGroupSearchFilter")
    if(searchText)
      regExp = Helpers.BuildRegExp(searchText);
      selector = {$or: [
        {name: regExp}
      ]}
    scope.customerGroupLists = Schema.customerGroups.find(selector, options).fetch()
    scope.customerGroupLists

  created: ->
    Session.set("customerGroupSearchFilter", "")
    Session.set("customerGroupCreationMode", false)

  events:
    "keyup input[name='searchFilter']": (event, template) ->
      Helpers.deferredAction ->
        searchFilter  = template.ui.$searchFilter.val()
        Session.set("customerGroupSearchFilter", searchFilter)

        if event.which is 17 then console.log 'up'
        else if event.which is 27 then scope.resetSearchFilter(template)
        else if event.which is 38 then scope.searchFindPreviousCustomerGroup()
        else if event.which is 40 then scope.searchFindNextCustomerGroup()
        else
          nameIsExisted = CustomerGroup.nameIsExisted(Session.get("customerGroupSearchFilter"), Session.get("myProfile").merchant)
          Session.set("customerGroupCreationMode", !nameIsExisted)
          scope.createNewCustomerGroup(template) if event.which is 13
      , "customerGroupSearchPeople"
      , 50

    "click .createCustomerGroupBtn": (event, template) -> scope.createNewCustomerGroup(template)
    "click .list .doc-item": (event, template) -> CustomerGroup.setSessionCustomerGroup(@_id)