lemon.defineWidget Template.customerManagementSaleDetails,
  helpers:
    isBase: -> @conversion is 1
    isDelete: -> moment().diff(@version.createdAt ? new Date(), 'days') < 1
    allowDelete: -> @_id isnt Template.parentData().transaction
    billNo: ->
      if @model is 'orders'
        'Số phiếu: ' + @orderCode + if @description then " (#{@description})" else ''
      else if @model is 'returns'
        'Trả hàng phiếu: ' + @returnCode + if @description then " (#{@description})" else ''

    detail: ->
      detail = @
      detail.totalPrice = detail.basicQuantity * detail.price

      if product = Schema.products.findOne({'units._id': detail.productUnit})
        productUnit = _.findWhere(product.units, {_id: detail.productUnit})
        detail.productName     = product.name
        detail.basicUnitName   = product.unitName()
        detail.productUnitName = productUnit.name

      detail


  events:
    "click .deleteTransaction": (event, template) ->
      event.stopPropagation()
      console.log @
      if @isRoot
        if User.hasManagerRoles()
          if Schema.orders.findOne(@parent)
            if @allowDelete then Meteor.call('deleteOrder', @parent) else console.log 'Order co Return'
          else if Schema.returns.findOne(@parent)
            if @allowDelete then Meteor.call('deleteReturn', @parent, @owner) else console.log 'Return loi'



      else
        Meteor.call 'deleteTransaction', @_id