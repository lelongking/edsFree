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
      Meteor.users.update(userId, {$set: {'sessions.currentStaff': @_id}}) if userId = Meteor.userId()


#    "keypress input[name='searchFilter']": (event, template)->
#      scope.createStaff(template) if event.which is 13 and Session.get("staffManagementCreationMode")
#    "click .createStaffBtn": (event, template) -> scope.createStaff(template)
#
#    "click .inner.caption": (event, template) ->
#      if Session.get("mySession")
#        Schema.userSessions.update(Session.get("mySession")._id, {$set: {currentStaffManagementSelection: @_id}})
#        limitExpand = Session.get("mySession").limitExpandSaleAndCustomSale ? 5
#        if staff = Schema.userProfiles.findOne(@_id)
##          countRecords = Schema.customSales.find({buyer: staff._id}).count()
##          countRecords += Schema.sales.find({buyer: staff._id}).count() if staff.customSaleModeEnabled is false
##          if countRecords is 0
##            Meteor.subscribe('staffManagementData', staff._id, 0, limitExpand)
##            Session.set("staffManagementDataMaxCurrentRecords", limitExpand)
##          else
##            Session.set("staffManagementDataMaxCurrentRecords", countRecords)
#          Session.set("staffManagementCurrentStaff", staff)
#
#        Session.set("allowCreateCustomSale", false)
#        Session.set("allowCreateTransactionOfCustomSale", false)
#
#        Session.set('currentRoleSelection', Schema.roles.find({_id: $in: staff.roles ? []}).fetch())
#
