lemon.defineWidget Template.customerManagementSaleDetails,
  helpers:
    allowDelete: -> @_id isnt Template.parentData().transaction
    billNo: ->
      if @model is 'orders'
        'Số phiếu: ' + @orderCode + if @description then " (#{@description})" else ''
      else if @model is 'returns'
        'Trả hàng phiếu: ' + @returnCode + if @description then " (#{@description})" else ''

  events:
    "click .deleteTransaction": (event, template) ->
      Meteor.call 'deleteTransaction', @_id
      event.stopPropagation()