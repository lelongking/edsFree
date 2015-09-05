Enums = Apps.Merchant.Enums
Apps.Merchant.staffManagementInit.push (scope) ->
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
        Meteor.call "createUserByEmail", email, '123', (error, result) ->
          Session.set("staffManagementSearchFilter", ''); template.ui.$searchFilter.val('')
          Session.set("staffManagementCreationMode", false)
          Meteor.users.update(Meteor.userId(), {$set: {'sessions.currentStaff': result}}) if result