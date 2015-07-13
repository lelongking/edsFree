scope = logics.providerManagement

lemon.defineHyper Template.providerManagementOverviewSection,
  helpers:
    avatarUrl: -> if @avatar then AvatarImages.findOne(@avatar)?.url() else undefined
    showEditCommand: -> Session.get "providerManagementShowEditCommand"
    showDeleteCommand: -> Session.get("providerManagementCurrentProvider")?.allowDelete

    name: ->
      Meteor.setTimeout ->
        scope.overviewTemplateInstance.ui.$providerName.change()
      , 50 if scope.overviewTemplateInstance
      @name

  rendered: ->
    scope.overviewTemplateInstance = @
    @ui.$providerName.autosizeInput({space: 10})
#    @ui.$providerPhone.autosizeInput({space: 10})
#    @ui.$providerAddress.autosizeInput({space: 10})

  events:
    "click .avatar": (event, template) -> template.find('.avatarFile').click()
    "change .avatarFile": (event, template) ->
      files = event.target.files
      if files.length > 0
        AvatarImages.insert files[0], (error, fileObj) ->
          Schema.providers.update(Session.get('providerManagementCurrentProvider')._id, {$set: {avatar: fileObj._id}})
          AvatarImages.findOne(Session.get('providerManagementCurrentProvider').avatar)?.remove()

    "input .editable": (event, template) -> scope.checkAllowUpdateProviderOverview(template)
    "keyup input.editable": (event, template) ->
      scope.editProvider(template) if event.which is 13

      if event.which is 27
        if $(event.currentTarget).attr('name') is 'providerName'
          $(event.currentTarget).val(Session.get("providerManagementCurrentProvider").name)
          $(event.currentTarget).change()
        else if $(event.currentTarget).attr('name') is 'providerPhone'
          $(event.currentTarget).val(Session.get("providerManagementCurrentProvider").phone)
        else if $(event.currentTarget).attr('name') is 'providerAddress'
          $(event.currentTarget).val(Session.get("providerManagementCurrentProvider").address)

        scope.checkAllowUpdateProviderOverview(template)

    "click .syncProviderEdit": (event, template) -> scope.editProvider(template)
    "click .providerDelete": (event, template) -> scope.currentProvider.remove(@)