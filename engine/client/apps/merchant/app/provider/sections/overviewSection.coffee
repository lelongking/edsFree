scope = logics.providerManagement

lemon.defineHyper Template.providerManagementOverviewSection,
  helpers:
    showEditCommand: -> Session.get "providerManagementShowEditCommand"
    showDeleteCommand: -> Session.get("providerManagementCurrentProvider")?.allowDelete

    name: ->
      Meteor.setTimeout ->
        scope.overviewTemplateInstance.ui.$providerName.change()
      , 50 if scope.overviewTemplateInstance
      @name

  rendered: ->
    Session.set('providerManagementIsShowProviderDetail', false)
    scope.overviewTemplateInstance = @
    @ui.$providerName.autosizeInput({space: 10})

  events:
    "click .avatar": (event, template) -> template.find('.avatarFile').click() if User.hasManagerRoles()
    "change .avatarFile": (event, template) ->
      if User.hasManagerRoles()
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
    "click .providerDetail span": (event, template)->
      Session.set('providerManagementIsShowProviderDetail', !Session.get('providerManagementIsShowProviderDetail'))

    "keyup .editDescription": (event, template) ->
      description = $(template.find(".editDescription")).val()
      provider = Session.get("providerManagementCurrentProvider")
      Helpers.deferredAction ->
        if provider
          Schema.providers.update(provider._id, $set:{description: description ? ""})
      , "providerManagementUpdateDescription"
      , 2000