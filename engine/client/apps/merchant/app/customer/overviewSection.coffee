@CustomerCreate = ()->
  Customer.insert(item.name, item.description) for item in a

scope = logics.customerManagement

lemon.defineHyper Template.customerManagementOverviewSection,
  rendered: ->
    Session.set('customerManagementIsShowCustomerDetail', false)
    scope.overviewTemplateInstance = @
    @ui.$customerName.autosizeInput({space: 10}) if @ui.$customerName

  helpers:
    showEditCommand: -> Session.get "customerManagementShowEditCommand"
    showDeleteCommand: -> Session.get("customerManagementCurrentCustomer")?.allowDelete
    name: ->
      Meteor.setTimeout ->
        scope.overviewTemplateInstance.ui.$customerName.change()
      ,50 if scope.overviewTemplateInstance?.ui.$customerName?
      @name
    firstName: -> Helpers.firstName(@name)

  events:
    "click .avatar": (event, template) ->
      if User.hasManagerRoles()
        template.find('.avatarFile').click()
    "change .avatarFile": (event, template) ->
      if User.hasManagerRoles()
        files = event.target.files
        if files.length > 0 and Session.get('customerManagementCurrentCustomer')
          AvatarImages.insert files[0], (error, fileObj) ->
            Schema.customers.update(Session.get('customerManagementCurrentCustomer')._id, {$set: {avatar: fileObj._id}})
            AvatarImages.findOne(Session.get('customerManagementCurrentCustomer').avatar)?.remove()

    "input .editable": (event, template) -> scope.checkAllowUpdateOverview(template)
    "keyup .editDescription": (event, template) ->
      description = $(template.find(".editDescription")).val()
      customer = Session.get("customerManagementCurrentCustomer")
      Helpers.deferredAction ->
        if customer
          Schema.customers.update(customer._id, $set:{description: description ? ""})
      , "customerManagementUpdateDescription"
      , 2000



    "keyup input.editable": (event, template) ->
      if Session.get("customerManagementCurrentCustomer")
        scope.editCustomer(template) if event.which is 13

        if event.which is 27
          if $(event.currentTarget).attr('name') is 'customerName'
            $(event.currentTarget).val(Session.get("customerManagementCurrentCustomer").name)
            $(event.currentTarget).change()
          else if $(event.currentTarget).attr('name') is 'customerPhone'
            $(event.currentTarget).val(Session.get("customerManagementCurrentCustomer").phone)
          else if $(event.currentTarget).attr('name') is 'customerAddress'
            $(event.currentTarget).val(Session.get("customerManagementCurrentCustomer").address)

          scope.checkAllowUpdateOverview(template)

    "click .syncCustomerEdit": (event, template) -> scope.editCustomer(template)
    "click .customerDelete": (event, template) -> scope.currentCustomer.remove()
    "click .customerDetail span": (event, template)->
      Session.set('customerManagementIsShowCustomerDetail', !Session.get('customerManagementIsShowCustomerDetail'))