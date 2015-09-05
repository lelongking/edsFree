Apps.Merchant.staffManagementInit.push (scope) ->
  scope.createStaff = (template) ->
    fullText    = Session.get("staffManagementSearchFilter")
    nameOptions = splitName(fullText)

    staff =
      parentMerchant   : Session.get('myProfile').parentMerchant
      currentMerchant  : Session.get('myProfile').currentMerchant
      currentWarehouse : Session.get('myProfile').currentWarehouse
      creator          : Session.get('myProfile').user
      fullName         : nameOptions.fullName
      gender           : nameOptions.gender ? true
      isRoot           : false
      styles           : Helpers.RandomColor()
    staff.gender = nameOptions.gender if nameOptions.gender

    existedQuery = {fullName: nameOptions.fullName, parentMerchant: Session.get('myProfile').parentMerchant}
#    existedQuery.description = nameOptions.description if nameOptions.description?.length > 0
    if Schema.userProfiles.findOne existedQuery
      template.ui.$searchFilter.notify("Tên nhân viên đã tồn tại.", {position: "bottom"})
    else
      Schema.userProfiles.insert staff, (error, result) ->
        console.log error if error
        MetroSummary.updateMetroSummaryBy(['staff'])
        UserSession.set('currentStaffManagementSelection', result)
      template.ui.$searchFilter.val(''); Session.set("staffManagementSearchFilter", "")




  scope.updateEmailOfStaff = (template) ->
    if staffProfile = Session.get("staffManagementCurrentStaff")
      email = $("[name='email']").val()
      password = $("[name='password']").val()
      confirm = $("[name='confirm']").val()

      console.log email
      console.log password
      console.log confirm

      if email.length > 0 and password.length > 0
        if password isnt confirm
          $("[name='confirm']").notify("Mật khẩu không chính xác.", {position: "bottom"})
        else if Meteor.users.findOne({'emails.address': email})
          $("[name='email']").notify("Email đã tồn tại.", {position: "bottom"})
        else
          Meteor.call "updateEmailStaff", email, password, staffProfile._id

splitName = (fullText) ->
  if fullText.indexOf("(") > 0
    namePart    = fullText.substr(0, fullText.indexOf("(")).trim()
    genderPart  = fullText.substr(fullText.indexOf("(")).replace("(", "").replace(")", "").trim()
    if genderPart.length > 0 then genderPart  = (Helpers.RemoveVnSigns genderPart).toLowerCase()

    option = { fullName: namePart }
    option.gender = if genderPart is 'nu' then false else true

    return option
  else
    return { fullName: fullText }