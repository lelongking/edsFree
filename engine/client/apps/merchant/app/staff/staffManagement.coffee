scope = logics.staffManagement
Enums = Apps.Merchant.Enums
lemon.defineApp Template.staffManagement,
  helpers:
    currentStaff: -> Session.get('staffManagementCurrentStaff')
    staffSearcher: ->
      selector = {}; options  = {sort: {'emails.address': 1}}; searchText = Session.get("staffManagementSearchFilter")
      if(searchText)
        regExp = Helpers.BuildRegExp(searchText);
        selector = {$or: [
          {'emails.address': regExp}
        ]}
      scope.staffSearcher = Meteor.users.find(selector, options).fetch()
      scope.staffSearcher

    getEmails: -> @emails?[0].address
    avatarUrl: -> if @profile and @profile.image then AvatarImages.findOne(@profile.image)?.url() else undefined
    permission: -> Enums.getObject('PermissionType', 'value')[@profile.roles].display


  created: ->
    Session.set("staffManagementSearchFilter", "")
    Session.set("staffManagementCreationMode", false)

  events:
    "keyup input[name='searchFilter']": (event, template) ->
      Helpers.deferredAction ->
        searchFilter  = template.ui.$searchFilter.val()
        Session.set("staffManagementSearchFilter", searchFilter)

        if event.which is 17 then console.log 'up'
#        else if event.which is 38 then scope.CustomerSearchFindPreviousCustomer(staffSearch)
#        else if event.which is 40 then scope.CustomerSearchFindNextCustomer(staffSearch)
        else
          scope.createNewStaff(template) if event.which is 13
          scope.staffManagementCreationMode()
      , "staffManagementSearchPeople"
      , 50

    "click .inner.caption": (event, template) ->
      if userId = Meteor.userId()
        Meteor.users.update(userId, {$set: {'sessions.currentStaff': @_id}})
#        $(".changeCustomer").select2("readonly", Meteor.users.findOne(@_id).sessions.customerOfStaffSelected.length < 1)
        Session.set('showCustomerListNotOfStaff', false)
        Session.set('staffManagementCustomerListNotOfStaffSelect', [])
