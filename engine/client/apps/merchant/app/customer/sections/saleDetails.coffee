lemon.defineWidget Template.customerManagementSaleDetails,
  helpers:
    allowDelete: -> @_id is Template.parentData().transaction
    billNo: ->
      if @model is 'orders' then 'Số phiếu: ' + @orderCode
      else if @model is 'returns' then 'Trả hàng phiếu: ' + @returnCode

  events:
    "click .deleteTransaction": (event, template) -> Meteor.call 'deleteTransaction', @_id