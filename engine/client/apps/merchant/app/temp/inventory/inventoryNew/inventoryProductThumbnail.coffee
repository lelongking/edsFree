calculateOriginalQuantity = (context) ->
  if context.lock == context.submit == false then return (Schema.productDetails.findOne(context.productDetail))?.inStockQuantity ? 0
  if context.lock != context.submit == false then return context.lockOriginalQuantity
  if context.lock == context.submit != false
    product = (Schema.productDetails.findOne(context.productDetail))?.inStockQuantity ? 0
    if context.originalQuantity != product
      Schema.inventoryDetails.update context._id, $set: {originalQuantity: product}
    else
      product

calculateSaleQuantity = (context) ->
  if context.lock == context.submit == false then return context.saleQuantity
  if context.lock != context.submit == false
    saleDetails = Schema.saleDetails.find(
      $and:
        [
          productDetail: context.productDetail
          status       : true
          exportDate   : {$gte: context.lockDate}
        ]).fetch()

    count = 0
    for detail in saleDetails
      count += detail.quality
    if count != context.saleQuantity
      realQuantity = context.realQuantity - (count - context.saleQuantity)
      Schema.inventoryDetails.update context._id, $set: {saleQuantity: count, realQuantity: realQuantity}
    return count

  if context.lock == context.submit != false
    saleDetails = Schema.saleDetails.find(
      $and:
        [
          productDetail: context.productDetail
          status       : true
          exportDate   : {$gte: context.submitDate}
        ]).fetch()
    count = 0
    for detail in saleDetails
      count += detail.quality
    if count != context.saleQuantity then (Schema.inventoryDetails.update context._id, $set: {saleQuantity: count})
    return count

calculateLostQuantity = (context) ->
  if context.lock == context.submit == false then return context.lostQuantity
  if context.lock != context.submit == false then return context.lostQuantity
  if context.lock == context.submit != false then return context.lostQuantity

calculateDate = (context) ->
  if context.lock == context.submit == false then return context.version.createdAt
  if context.lock != context.submit == false then return context.lockDate
  if context.lock == context.submit != false then return context.submitDate

calculateRealQuantity = (context) ->
  if context.lock == context.submit == false then return 0
  if context.lock != context.submit == false
    context.realQuantity



  if context.lock == context.submit != false
    saleDetails = Schema.saleExports.find(
      $and:
        [
          productDetail: context.productDetail
          'version.createdAt': {$gte: context.submitDate}
        ]).fetch()
    count = 0
    for detail in saleDetails
      count += detail.qualityExport
    if count != context.saleQuantity
      Schema.inventoryDetails.update context._id, $set: {saleQuantity: count}
    return count

lemon.defineWidget Template.inventoryProductThumbnail,
  colorClass: ->
    if @lock == @submit == false then return 'lime'
    if @lostQuantity > 0 then 'pumpkin' else 'belize-hole'

  productDetail: -> Schema.productDetails.findOne(@productDetail)
  expireDate: (date)-> if date then date.toDateString() else ''

  originalQuantity: -> calculateOriginalQuantity(@)
  saleQuantity: -> calculateSaleQuantity(@)
#  lostQuantity: -> calculateLostQuantity(@)
  date: -> calculateDate(@)
  status: ->
    if @lock == @submit == false then return 'New'
    if @lock != @submit == false then return 'Locked'
    if @lock == @submit != false then return 'Submitted'

  hideLock:  -> unless @lock == @submit == false then return "display: none"
  hideCheck: -> unless @lock != @submit == false then return "display: none"
  hideReply: -> unless @lock == @submit != false then return "display: none"

  showDescription: ->
    if Session.get('inventoryWarehouse')?.checkingInventory == true and !Session.get("currentInventory") and Session.get("historyInventories")
      return "display: none"


  realQuantityOptions: ->
    {
      parentContext: @
      reactiveSetter: (val) ->
        if @parentContext.lock != @parentContext.submit == false  and @parentContext.success == false
          option={}
          maxQuantity = @parentContext.lockOriginalQuantity - @parentContext.saleQuantity
          if val < maxQuantity
            option.realQuantity = val
            option.lostQuantity = maxQuantity - val
          else
            option.realQuantity = maxQuantity
            option.lostQuantity = 0
          Schema.inventoryDetails.update @parentContext._id, $set: option
      reactiveValue: -> @parentContext.realQuantity ? 0
      reactiveMax: -> @parentContext.lockOriginalQuantity - @parentContext.saleQuantity
      reactiveMin: -> 0
      reactiveStep: -> 1
    }

  events:
    "click .icon-lock": (event, template)->
      if @lock == @submit == @success == false
        productDetail = Schema.productDetails.findOne(@productDetail)
        Schema.inventoryDetails.update @_id, $set: {
          lock: true
          lockDate: new Date
          lockOriginalQuantity: productDetail.inStockQuantity
          realQuantity    : productDetail.inStockQuantity
          saleQuantity    : 0
          lostQuantity    : 0
        }

    "click .icon-ok-6": (event, template)->
      if @lock != @submit == @success == false
        productDetail = Schema.productDetails.findOne(@productDetail)
        Schema.inventoryDetails.update @_id, $set: {
          submit: true
          submitDate: new Date
        }

    "click .icon-reply-3": (event, template)->
      if @lock == @submit != @success == false
        Schema.inventoryDetails.update @_id, $set: {
          submit      : false
          realQuantity : @lockOriginalQuantity - @saleQuantity - @lostQuantity
        }