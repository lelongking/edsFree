scope = logics.customerGroup

lemon.defineApp Template.customerGroupOverviewSection,
  helpers:
    customerGroupSelects: -> scope.customerGroupSelects
    customerSelectedCount: -> Session.get("customerSelectLists")?.length > 0
  #  showEditCommand: -> Session.get "customerGroupShowEditCommand"
    name: ->
      Meteor.setTimeout ->
        scope.overviewTemplateInstance.ui.$customerGroupName.change()
      ,50 if scope.overviewTemplateInstance?.ui.$customerGroupName?
      @name

  rendered: ->
    scope.overviewTemplateInstance = @
    @ui.$customerGroupName.autosizeInput({space: 10}) if @ui.$customerGroupName
    changeCustomerReadonly = if Session.get("customerSelectLists") then Session.get("customerSelectLists").length is 0 else true
    $(".changeCustomer").select2("readonly", changeCustomerReadonly)


  events:
#    "click .avatar": (event, template) -> template.find('.avatarFile').click()
#    "change .avatarFile": (event, template) ->
#      files = event.target.files
#      if files.length > 0
#        AvatarImages.insert files[0], (error, fileObj) ->
#          Schema.customers.update(Session.get('currentCustomerGroup')._id, {$set: {avatar: fileObj._id}})
#          AvatarImages.findOne(Session.get('currentCustomerGroup').avatar)?.remove()

    "input .editable": (event, template) -> scope.checkAllowUpdateOverviewCustomerGroup(template)
    "keyup input.editable": (event, template) ->
      if Session.get("currentCustomerGroup")
        scope.editCustomerGroup(template) if event.which is 13

        if event.which is 27
          if $(event.currentTarget).attr('name') is 'customerGroupName'
            $(event.currentTarget).val(Session.get("currentCustomerGroup").name)
            $(event.currentTarget).change()
          else if $(event.currentTarget).attr('name') is 'customerGroupDescription'
            $(event.currentTarget).val(Session.get("currentCustomerGroup").description)

          scope.checkAllowUpdateOverviewCustomerGroup(template)

    "click .syncCustomerEdit": (event, template) -> scope.editCustomer(template) if User.hasManagerRoles()
    "click .customerDelete": (event, template) -> scope.currentCustomerGroup.remove() if User.hasManagerRoles()