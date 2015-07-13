scope = logics.providerManagement

lemon.defineWidget Template.providerManagementCustomImportDetails,
  productName: -> @productName
  receivableClass: -> if @debtBalanceChange >= 0 then 'paid' else 'receive'
  finalReceivableClass: -> if @latestDebtBalance >= 0 then 'receive' else 'paid'
  latestPaids: -> Schema.transactions.find {latestImport: @_id}, {sort: {'version.createdAt': 1}}
  customImportDetails: ->
    customImportId = Template.instance().data._id
    Schema.customImportDetails.find({customImport: customImportId})

  isCustomImportModeEnabled: ->
    provider = Session.get("providerManagementCurrentProvider")
    if @allowDelete and provider?.customImportModeEnabled then true else false

  isCustomImportDetailCreator: ->
    provider = Session.get("providerManagementCurrentProvider")
    if provider?.customImportModeEnabled
      if @allowDelete then true
      else
        transaction = Schema.transactions.findOne({owner: provider._id, allowDelete: true}, {sort: {debtDate: -1}})
        if transaction?.latestImport is @_id then true else false
    else
      false

  events:
    "click .enter-edit": (event, template) -> Session.set("providerManagementCurrentCustomImport", @)
    "click .cancel-edit": (event, template) -> Session.set("providerManagementCurrentCustomImport")

    "click .deleteCustomImport": (event, template) -> Meteor.call('deleteCustomImport', @_id)
    "click .deleteCustomImportDetail": (event, template) -> Meteor.call('updateCustomImportByDeleteCustomImportDetail', @_id)
    "click .deleteTransaction": (event, template) -> Meteor.call('deleteTransactionOfCustomImport', @_id)



lemon.defineWidget Template.providerManagementCustomImportDetailCreator,
  rendered: ->
    if $(@find("[name='price']"))
      $(@find("[name='price']")).inputmask "numeric",
        {autoGroup: true, groupSeparator:",", radixPoint: ".", suffix: " VNĐ", integerDigits:11}

    if $(@find("[name='totalPrice']"))
      $(@find("[name='totalPrice']")).inputmask "numeric",
        {autoGroup: true, groupSeparator:",", radixPoint: ".", suffix: " VNĐ", integerDigits:11}

  events:
    "click .createCustomImportDetail": (event, template) -> scope.createCustomImportDetail(template, @)
    "keypress input": (event, template) ->
      if event.which is 13 #ENTER
        scope.createCustomImportDetail(template, @)
      else if event.which is 27
        $(template.find("[name='productName']")).val('')
        $(template.find("[name='price']")).val('')
        $(template.find("[name='quality']")).val('')
        $(template.find("[name='skulls']")).val('')