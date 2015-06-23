Apps.Merchant.deliveryInit.push (scope) ->
  scope.waitingGridOptions =
    itemTemplate: 'deliveryThumbnail'
    reactiveSourceGetter: -> scope.waitingDeliveries
  scope.deliveringGridOptions =
    itemTemplate: 'deliveryThumbnail'
    reactiveSourceGetter: -> scope.deliveringDeliveries
  scope.doneGridOptions =
    itemTemplate: 'deliveryThumbnail'
    reactiveSourceGetter: -> scope.doneDeliveries