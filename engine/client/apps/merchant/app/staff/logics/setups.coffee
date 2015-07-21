formatGender         = (item) -> "#{item.display}" if item
formatDefaultSearch  = (item) -> "#{item.display}" if item
findPermissionType   = (permissionId)-> _.findWhere(Enums.PermissionType, {value: permissionId}) ? 'skyReset'

Enums = Apps.Merchant.Enums
Apps.Merchant.staffManagementInit.push (scope) ->
  scope.roleSelectOptions =
    query: (query) -> query.callback
      results: Enums.PermissionType
      text: 'value'
    initSelection: (element, callback) -> callback findPermissionType(Session.get('staffManagementCurrentStaff')?.profile.roles)
    formatSelection: formatDefaultSearch
    formatResult: formatDefaultSearch
    placeholder: 'CHỌN SẢN PTGD'
    minimumResultsForSearch: -1
    changeAction: (e) -> Meteor.users.update(Session.get("staffManagementCurrentStaff")._id, $set:{'profile.roles': e.added.value})
    reactiveValueGetter: -> findPermissionType(Session.get('staffManagementCurrentStaff')?.profile.roles)

#  scope.roleSelectOptions =
#    query: (query) -> query.callback
#      results: Schema.roles.find().fetch()
#    initSelection: (element, callback) -> callback Session.get('currentRoleSelection')
#    changeAction: (e) ->
#      currentRoles = Session.get('currentRoleSelection')
#      currentRoles = currentRoles ? []
#
#      currentRoles.push e.added if e.added
#      if e.removed
#        removedItem = _.findWhere(currentRoles, {_id: e.removed._id})
#        currentRoles.splice currentRoles.indexOf(removedItem), 1
#
#      Session.set('currentRoleSelection', currentRoles)
#      Schema.userProfiles.update Session.get("staffManagementCurrentStaff")._id, $set: {roles: _.pluck(currentRoles, '_id')}
#    reactiveValueGetter: -> Session.get('currentRoleSelection')
#    formatSelection: formatRoleSelect
#    formatResult: formatRoleSelect
#    others:
#      multiple: true
#      maximumSelectionSize: 3

  scope.genderSelectOptions =
    query: (query) -> query.callback
      results: Apps.Merchant.Enums.GenderTypes
      text: 'id'
    initSelection: (element, callback) ->
      callback _.findWhere(Apps.Merchant.Enums.GenderTypes, {_id: Session.get("staffManagementCurrentStaff")?.profile.gender})
    reactiveValueGetter: -> _.findWhere(Apps.Merchant.Enums.GenderTypes, {_id: Session.get("staffManagementCurrentStaff")?.profile.gender})
    changeAction: (e) ->
      Meteor.users.update Session.get("staffManagementCurrentStaff")._id, $set: {'profile.gender': e.added._id}

    formatSelection: formatGender
    formatResult: formatGender
    placeholder: 'CHỌN GIỚI TÍNH'
    minimumResultsForSearch: -1