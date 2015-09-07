lemon.defineWidget Template.providerManagementImportDetails,
  helpers:
    isDelete: -> moment().diff(@version.createdAt ? new Date(), 'days') < 1
    isColor: -> '#fff'
#      if Template.parentData().classColor then '#fff' else '#f0f0f0'
    allowDelete: -> @_id isnt Template.parentData().transaction
    billNo: ->
      if @model is 'imports'
        'Số phiếu: ' + @importCode + if @description then " (#{@description})" else ''
      else if @model is 'returns'
        'Trả hàng phiếu: ' + @returnCode + if @description then " (#{@description})" else ''

  events:
    "click .deleteTransaction": (event, template) ->
      Meteor.call 'deleteTransaction', @_id
      event.stopPropagation()

