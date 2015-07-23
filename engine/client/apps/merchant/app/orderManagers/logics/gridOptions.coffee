Apps.Merchant.orderManagerInit.push (scope) ->
  logics.orderManager.gridOptions =
    itemTemplate: 'orderThumbnail'
    reactiveSourceGetter: -> logics.orderManager.availableBills
    wrapperClasses: 'detail-grid row'