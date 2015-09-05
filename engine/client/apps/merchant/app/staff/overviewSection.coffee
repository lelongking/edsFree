scope = logics.staffManagement

lemon.defineHyper Template.staffManagementOverviewSection,
  helpers:
    genderSelectOptions: -> scope.genderSelectOptions
    roleSelectOptions: -> scope.roleSelectOptions
    customerGroupSelects: -> scope.customerGroupSelects


    userName: -> @emails?[0]?.address ? 'chưa tạo tài khoản đăng nhập.'
    genderName: -> if @profile?.gender then 'Nam' else 'Nữ'
    avatarUrl: -> if @profile and @profile.image then AvatarImages.findOne(@profile.image)?.url() else undefined
    fullName: ->
      Meteor.setTimeout ->
        scope.overviewTemplateInstance.ui.$staffName.change()
      ,50 if scope.overviewTemplateInstance
      @profile?.name


  rendered: ->
    scope.overviewTemplateInstance = @
    @ui.$staffName.autosizeInput({space: 10})
    if Template.currentData().creator
      $(".roleSelect").select2("readonly", Template.currentData().creator is undefined)
      $(".changeCustomer").select2("readonly", Template.currentData().creator is undefined)


  events:
    "click .avatar": (event, template) -> template.find('.avatarFile').click() if User.hasAdminRoles()
    "change .avatarFile": (event, template) ->
      if User.hasAdminRoles()
        files = event.target.files
        if files.length > 0
          AvatarImages.insert files[0], (error, fileObj) ->
            Meteor.users.update Session.get('staffManagementCurrentStaff')._id, $set: {"profile.image": fileObj._id}
            AvatarImages.findOne(Session.get('staffManagementCurrentStaff').profile.image)?.remove()

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

    #delete staff
    "click .staffDelete": (event, template) ->
      if staff = Session.get("staffManagementCurrentStaff")
        if staff.allowDelete and staff._id isnt Session.get('myProfile')._id
          if Meteor.users.remove(staff._id)
            Meteor.users.update(Meteor.userId(), {$set: {'sessions.currentStaff': Meteor.users.findOne()?._id ? ''}})

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