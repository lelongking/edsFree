scope = logics.staffManagement

lemon.defineHyper Template.staffManagementOverviewSection,
  helpers:
    userName: -> @emails[0].address ? 'chưa tạo tài khoản đăng nhập.'
    genderName: -> if @profile.gender then 'Nam' else 'Nữ'

    fullName: ->
      Meteor.setTimeout ->
        scope.overviewTemplateInstance.ui.$staffName.change()
      ,50 if scope.overviewTemplateInstance
      @profile.name

    genderSelectOptions: -> scope.genderSelectOptions
    roleSelectOptions: -> scope.roleSelectOptions

  rendered: ->
    scope.overviewTemplateInstance = @
    @ui.$staffName.autosizeInput({space: 10})

  events:
#    "click .avatar": (event, template) -> template.find('.avatarFile').click()
#    "change .avatarFile": (event, template) ->
#      files = event.target.files
#      if files.length > 0
#        AvatarImages.insert files[0], (error, fileObj) ->
#          Schema.userProfiles.update(Session.get('staffManagementCurrentStaff')._id, {$set: {avatar: fileObj._id}})
#          AvatarImages.findOne(Session.get('staffManagementCurrentStaff').avatar)?.remove()

    "input .editable": (event, template) ->
      if staff = Session.get("staffManagementCurrentStaff")
        Session.set "staffManagementShowEditCommand", template.ui.$staffName.val() isnt staff.profile.name

    "keyup input.editable": (event, template) ->
      if staff = Session.get("staffManagementCurrentStaff")
        if event.which is 27
          if $(event.currentTarget).attr('name') is 'staffName'
            $(event.currentTarget).val(staff.profile.name); $(event.currentTarget).change()
        else  if event.which is 13 then scope.editStaff(template)
        Session.set "staffManagementShowEditCommand", template.ui.$staffName.val() isnt staff.profile.name

    "click .syncStaffEdit": (event, template) -> scope.editStaff(template)

    "click .staffDelete": (event, template) ->
      if staff = Session.get("staffManagementCurrentStaff")
        if staff.allowDelete and staff._id isnt Session.get('myProfile')._id
          Schema.userProfiles.remove staff._id
          UserSession.set('currentStaffManagementSelection', Schema.userProfiles.findOne()?._id ? '')