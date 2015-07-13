@PriceBookCreate = ()->
  PriceBook.insert(item.name, item.description) for item in a


scope = logics.priceBook

lemon.defineHyper Template.priceBookOverviewSection,
  helpers:
    priceBookSelectOptions : -> scope.priceBookSelectOptions
    priceProductSelectedCount: -> Session.get("priceProductLists")?.length > 0
    name: ->
      Meteor.setTimeout ->
        scope.overviewTemplateInstance.ui.$priceBookName.change()
      ,50 if scope.overviewTemplateInstance
      @name
    firstName: -> Helpers.firstName(@name)

  rendered: ->
    scope.overviewTemplateInstance = @
    @ui.$priceBookName.autosizeInput({space: 10})

  events:
    "click .avatar": (event, template) -> template.find('.avatarFile').click()
    "change .avatarFile": (event, template) ->
      files = event.target.files
      if files.length > 0
        AvatarImages.insert files[0], (error, fileObj) ->
          Schema.priceBooks.update(Session.get('priceBookManagementCurrentPriceBook')._id, {$set: {avatar: fileObj._id}})
          AvatarImages.findOne(Session.get('priceBookManagementCurrentPriceBook').avatar)?.remove()

    "input .editable": (event, template) -> scope.checkAllowUpdateOverview(template)
    "keyup input.editable": (event, template) ->
      if Session.get("priceBookManagementCurrentPriceBook")
        scope.editPriceBook(template) if event.which is 13

        if event.which is 27
          if $(event.currentTarget).attr('name') is 'priceBookName'
            $(event.currentTarget).val(Session.get("priceBookManagementCurrentPriceBook").name)
            $(event.currentTarget).change()
          else if $(event.currentTarget).attr('name') is 'priceBookPhone'
            $(event.currentTarget).val(Session.get("priceBookManagementCurrentPriceBook").phone)
          else if $(event.currentTarget).attr('name') is 'priceBookAddress'
            $(event.currentTarget).val(Session.get("priceBookManagementCurrentPriceBook").address)

          scope.checkAllowUpdateOverview(template)

    "click .syncPriceBookEdit": (event, template) -> scope.editPriceBook(template)
    "click .priceBookDelete": (event, template) -> scope.currentPriceBook.remove()