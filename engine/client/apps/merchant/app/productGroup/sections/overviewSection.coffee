scope = logics.productGroup

lemon.defineApp Template.productGroupOverviewSection,
  helpers:
    productGroupSelects: -> scope.productGroupSelects
    productSelectedCount: -> Session.get("productSelectLists")?.length > 0
  #  showEditCommand: -> Session.get "productGroupShowEditCommand"
    name: ->
      Meteor.setTimeout ->
        scope.overviewTemplateInstance.ui.$productGroupName.change()
      ,50 if scope.overviewTemplateInstance?.ui.$productGroupName?
      @name

  rendered: ->
    scope.overviewTemplateInstance = @
    @ui.$productGroupName.autosizeInput({space: 10}) if @ui.$productGroupName


  events:
#    "click .avatar": (event, template) -> template.find('.avatarFile').click()
#    "change .avatarFile": (event, template) ->
#      files = event.target.files
#      if files.length > 0
#        AvatarImages.insert files[0], (error, fileObj) ->
#          Schema.products.update(Session.get('currentProductGroup')._id, {$set: {avatar: fileObj._id}})
#          AvatarImages.findOne(Session.get('currentProductGroup').avatar)?.remove()

    "input .editable": (event, template) -> scope.checkAllowUpdateOverviewProductGroup(template)
    "keyup input.editable": (event, template) ->
      if Session.get("currentProductGroup")
        scope.editProductGroup(template) if event.which is 13 and User.hasManagerRoles()

        if event.which is 27
          if $(event.currentTarget).attr('name') is 'productGroupName'
            $(event.currentTarget).val(Session.get("currentProductGroup").name)
            $(event.currentTarget).change()
          else if $(event.currentTarget).attr('name') is 'productGroupDescription'
            $(event.currentTarget).val(Session.get("currentProductGroup").description)

          scope.checkAllowUpdateOverviewProductGroup(template)

    "click .syncProductEdit": (event, template) -> scope.editProduct(template) if User.hasManagerRoles()
    "click .productDelete": (event, template) -> scope.currentProductGroup.remove() if User.hasManagerRoles()