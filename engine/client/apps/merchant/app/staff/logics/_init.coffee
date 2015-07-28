logics.staffManagement = {}
Apps.Merchant.staffManagementInit = []
Apps.Merchant.staffManagementReactive = []

Apps.Merchant.staffManagementReactive.push (scope) ->
  if staffId = Session.get("mySession")?.currentStaff
    scope.currentStaff = Meteor.users.findOne(staffId)
    Session.set("staffManagementCurrentStaff", scope.currentStaff)

  staff = Session.get('staffManagementCurrentStaff')
  if staff
    if staff.creator
      $(".roleSelect").select2("readonly", false)
    else
      $(".roleSelect").select2("readonly", true)
  else
    $(".roleSelect").select2("readonly", true)
    $(".genderSelect").select2("readonly", true)

Apps.Merchant.staffManagementInit.push (scope) ->
  scope.staffManagementCreationMode = ->
    if Session.get("staffManagementSearchFilter").length > 0
      if scope.staffSearcher.length is 0 then nameIsExisted = true
      else if scope.staffSearcher.length is 1
        nameIsExisted = scope.staffSearcher[0].emails[0].address isnt Session.get("staffManagementSearchFilter")
    Session.set("staffManagementCreationMode", nameIsExisted)

  scope.createNewStaff = (template) ->
    if Session.get("staffManagementCreationMode")
      email = Session.get("staffManagementSearchFilter")
      staffFound = Meteor.users.findOne({'emails.address': email}) if email.length > 0

      if email.length is 0
        template.ui.$searchFilter.notify("Tên nhân viên không thể để trống.", {position: "right"})
      else if staffFound and staffFound._id isnt staff._id
        template.ui.$searchFilter.notify("Tên nhân viên đã tồn tại.", {position: "right"})
        template.ui.$searchFilter.val email
        Session.set("staffManagementCreationMode", false)
      else
        template.ui.$searchFilter.val email
        Meteor.call "createUserByEmail", email, '123', (error, result) ->
          Session.set("staffManagementCreationMode", false)

  scope.editStaff = (template) ->
    staff = Session.get("staffManagementCurrentStaff")
    if staff and Session.get("staffManagementShowEditCommand")
      fullText = template.ui.$staffName.val()
      nameOptions = splitName(fullText)

      if nameOptions['profile.name'].length is 0
        template.ui.$staffName.notify("Tên nhân viên không thể để trống.", {position: "right"})
#      else if staffFound and staffFound._id isnt staff._id
#        template.ui.$staffName.notify("Tên nhân viên đã tồn tại.", {position: "right"})
#        template.ui.$staffName.val nameOptions['profile.name']
#        Session.set("staffManagementShowEditCommand", false)
      else
        template.ui.$staffName.val nameOptions['profile.name']
        Session.set("staffManagementShowEditCommand", false)
        Meteor.users.update(staff._id, $set: nameOptions)

splitName = (fullText) ->
  if fullText.indexOf("(") > 0
    namePart    = fullText.substr(0, fullText.indexOf("(")).trim()
    genderPart  = fullText.substr(fullText.indexOf("(")).replace("(", "").replace(")", "").trim()
    if genderPart.length > 0 then genderPart  = (Helpers.RemoveVnSigns genderPart).toLowerCase()

    option = {'profile.name': namePart }
    option['profile.gender'] = if genderPart is 'nu' then false else true

    return option
  else
    return { 'profile.name': fullText }