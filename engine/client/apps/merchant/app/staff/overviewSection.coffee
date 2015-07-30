scope = logics.staffManagement

lemon.defineHyper Template.staffManagementOverviewSection,
  helpers:
    userName: -> @emails?[0]?.address ? 'chưa tạo tài khoản đăng nhập.'
    genderName: -> if @profile?.gender then 'Nam' else 'Nữ'

    fullName: ->
      Meteor.setTimeout ->
        scope.overviewTemplateInstance.ui.$staffName.change()
      ,50 if scope.overviewTemplateInstance
      @profile?.name

    genderSelectOptions: -> scope.genderSelectOptions
    roleSelectOptions: -> scope.roleSelectOptions
    customerGroupSelects: -> scope.customerGroupSelects

  rendered: ->
    scope.overviewTemplateInstance = @
    @ui.$staffName.autosizeInput({space: 10})
    $(".roleSelect").select2("readonly", Template.currentData().creator is undefined)
    $(".changeCustomer").select2("readonly", Template.currentData().creator is undefined)

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

    "click .addCustomerToStaff": (event, template)->
      if Session.get('showCustomerListNotOfStaff')
        staffId      = Session.get("staffManagementCurrentStaff")._id
        customerList = Session.get('staffManagementCustomerListNotOfStaffSelect')
        list = []

        if staffId and customerList?.length > 0
          for customerId in customerList
            if customer = Schema.customers.findOne({_id:customerId, staff: {$exists: false} })
              list.push(customer._id)
              Schema.customers.update customer._id, $set:{staff: staffId}

          if list.length > 0
            Meteor.users.update staffId, $addToSet:{'profile.customers': {$each: list}}
            Session.set('showCustomerListNotOfStaff', false)
            Session.set('staffManagementCustomerListNotOfStaffSelect', [])