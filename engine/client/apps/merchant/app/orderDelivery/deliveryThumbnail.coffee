lemon.defineWidget Template.deliveryThumbnail,
  helpers:
  #  showSelectCommand:  -> @delivery.status is 1 ko co nhan giao hang
    showStartCommand:   -> @delivery.status is 1
    showConfirmCommand: -> @delivery.status is 2
    showFinishCommand:  -> @delivery.status is 3 or @delivery.status is 4
    showCancelCommand:  -> _.contains([2, 3, 4], @delivery.status)

  #  showAccountingCommand:  -> @delivery.status is 5
  #  showExportCommand:      -> @delivery.status is 2
  #  showImportCommand:      -> @delivery.status is 8

    showStatus: (status) ->
      switch status
        when 1 then 'Chưa Giao Hàng '
        when 2 then 'Đang Giao Hàng'
        when 3 then 'Giao Thất Bại'
        when 4 then 'Giao Thành Công'

    buttonSuccessText: (status) ->
      switch status
        when 1 then 'nhận đơn giao hàng'
        when 3 then 'xác nhận đi giao hàng'
        when 4 then 'Thành Công'
        when 5 then 'Chờ Xác Nhận Của Kế Toán'
        when 6 then 'Xác Nhận'
        when 8 then 'Chờ Xác Nhân Của Kho'
        when 9 then 'Xác Nhận'

    buttonUnSuccessText: (status) -> 'Thất Bại' if status == 4
    hideButtonSuccess: (status)-> return "display: none" if _.contains([2,5,7,8,10],status)
    hideButtonUnSuccess: (status)-> return "display: none" unless status == 4
    customerAlias: -> Schema.customers.findOne(@buyer)?.name ? @contactName

  events:
#    "click .select-command": (event, template) -> #nhân giao hàng
#      Meteor.call "updateDelivery", @_id, 'select', (error, result) -> console.log error if error

    "click .start-command": -> #đang giao hàng
      Schema.orders.update @_id, {$set:{'delivery.status': 2}}

    "click .fail-command": ->
      if @delivery.status is 2
        Schema.orders.update @_id, {$set:{'delivery.status': 3}}

    "click .success-command": ->
      if @delivery.status is 2
        Schema.orders.update @_id, {$set:{'delivery.status': 4}}

    "click .finish-command": ->
      if _.contains([3, 4], @delivery.status)
        Schema.orders.update @_id, {$set:{'delivery.status': 5}}

    "click .cancel-command": (event, template) ->
      if _.contains([3, 4], @delivery.status)
        Schema.orders.update @_id, {$set:{'delivery.status': 2}}
      else if @delivery.status is 2
        Schema.orders.update @_id, {$set:{'delivery.status': 1}}

#    "click .accounting-command": ->
#      Meteor.call 'confirmReceiveSale', @sale, (error, result) -> if error then console.log error
#
#    "click .export-command": ->
#      Meteor.call 'createSaleExport', @sale, (error, result) -> if error then console.log error
#
#    "click .import-command": ->
#      Meteor.call 'createSaleImport', @sale, (error, result) -> if error then console.log error