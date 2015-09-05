formatGender         = (item) -> "#{item.display}" if item
formatDefaultSearch  = (item) -> "#{item.display}" if item
formatCustomerSearch = (item) -> "#{item.profile.name}" if item
findPermissionType   = (permissionId)-> _.findWhere(Enums.PermissionType, {value: permissionId}) ? 'skyReset'

Enums = Apps.Merchant.Enums
Apps.Merchant.staffManagementInit.push (scope) ->
  scope.customerGroupSelects =
    query: (query) -> query.callback
      results: Meteor.users.find({_id: {$not: Session.get("mySession").currentStaff}}).fetch()
      text: 'name'
    initSelection: (element, callback) -> callback 'skyReset'
    formatSelection: formatCustomerSearch
    formatResult: formatCustomerSearch
    id: '_id'
    placeholder: 'CHỌN NHÓM'
    changeAction: (e) ->
      formStaff = Session.get('staffManagementCurrentStaff')
      toStaff   = e.added
      customerList = Session.get('customerOfStaffSelectLists')

      if formStaff and toStaff and customerList.length > 0
        checkCustomerList = []
        for customerId in customerList
          if customer = Schema.customers.findOne({_id:customerId, staff: formStaff._id})
            checkCustomerList.push(customer._id)
            Schema.customers.update customer._id, $set:{staff: toStaff._id}

        userUpdate = $set:{}; userUpdate.$set["sessions.customerOfStaffSelected.#{Session.get("mySession").currentStaff}"] = []
        Meteor.users.update(Meteor.userId(), userUpdate)

        Meteor.users.update(formStaff._id, $pullAll:{'profile.customers': customerList })
        Meteor.users.update(toStaff._id, $addToSet:{'profile.customers': {$each: checkCustomerList}}) if checkCustomerList.length > 0

        Session.set('staffManagementResetCustomerSelect', '')
        Session.set('staffManagementResetCustomerSelect', 'skyReset')
      return false
    reactiveValueGetter: -> Session.get('staffManagementResetCustomerSelect')


  scope.roleSelectOptions =
    query: (query) -> query.callback
      results: Enums.PermissionType
      text: 'value'
    initSelection: (element, callback) -> callback findPermissionType(Session.get('staffManagementCurrentStaff')?.profile.roles)
    formatSelection: formatDefaultSearch
    formatResult: formatDefaultSearch
    placeholder: 'CHỌN PHÂN QUYỀN'
    minimumResultsForSearch: -1
    changeAction: (e) -> Meteor.users.update(Session.get("staffManagementCurrentStaff")._id, $set:{'profile.roles': e.added.value})
    reactiveValueGetter: -> findPermissionType(Session.get('staffManagementCurrentStaff')?.profile.roles)


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