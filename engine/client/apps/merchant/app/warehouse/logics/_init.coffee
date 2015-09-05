Enums = Apps.Merchant.Enums
logics.warehouse = {warehouseDetail: {totalCostPrice: 0, totalRevenue: 0}}
Apps.Merchant.warehouseInit = []
Apps.Merchant.warehouseReactive = []


findProductTrade =
  Schema.products.find(
    {$or: [
      {'qualities.saleQuality'     : {$ne: 0}}
      {'qualities.inStockQuality'  : {$ne: 0}}
    ]}
    {
      sort:
        allQuality           : -1
        upperGapQualityCount : 1
    }
  )

findProductNotTrade =
  Schema.products.find(
    {
      'qualities.saleQuality'     : 0
      'qualities.inStockQuality'  : 0
    }
    {
      sort:
        upperGapQualityCount : -1
    }
  )

Apps.Merchant.warehouseReactive.push (scope) ->

Apps.Merchant.warehouseInit.push (scope) ->
  scope.listProductsNotTrade = ->
    productCount = findProductTrade.count(); totalCostPrice = 0; totalRevenue = 0
    lists = findProductNotTrade.map(
      (product) ->
        productCount += 1; product.count = productCount; basicUnitId = product.basicUnit()
        costPrice = product.qualities[0].inStockQuality * product.getPrice(basicUnitId, undefined, 'import')
        revenue   = product.qualities[0].inStockQuality * product.getPrice(basicUnitId)

        product.costPrice = costPrice ? 0
        product.revenue   = revenue ? 0
        totalCostPrice += product.costPrice
        totalRevenue   += product.revenue

        product
    )
    return {
      details       : lists
      totalCostPrice: totalCostPrice
      totalRevenue  : totalRevenue
    }

  scope.listProductsTrade = (count = 0)->
    productCount = count; totalCostPrice = 0; totalRevenue = 0
    lists = findProductTrade.map(
      (product) ->
        productCount += 1; product.count = productCount; basicUnitId = product.basicUnit()
        costPrice = product.qualities[0].inStockQuality * product.getPrice(basicUnitId, undefined, 'import')
        revenue   = product.qualities[0].inStockQuality * product.getPrice(basicUnitId)

        product.costPrice = costPrice ? 0
        product.revenue   = revenue ? 0
        totalCostPrice += product.costPrice
        totalRevenue   += product.revenue

        product
    )
    return {
      details       : lists
      totalCostPrice: totalCostPrice
      totalRevenue  : totalRevenue
    }